import '../../models/announcement_model.dart';
import '../../services/authority_service.dart';
import '../announcement_repository.dart';
import '../profile_repository.dart';

class RealAnnouncementRepository implements AnnouncementRepository {
  RealAnnouncementRepository({
    required AuthorityService authorityService,
    required ProfileRepository profileRepository,
  })  : _authorityService = authorityService,
        _profileRepository = profileRepository;

  final AuthorityService _authorityService;
  final ProfileRepository _profileRepository;

  final Set<String> _readIds = <String>{};
  final Map<String, AnnouncementModel> _cache = <String, AnnouncementModel>{};

  @override
  Future<List<AnnouncementModel>> getAnnouncements({
    AnnouncementSource? source,
    int page = 1,
    int limit = 20,
  }) async {
    if (source == null) {
      final chunks = await Future.wait<List<AnnouncementModel>>([
        _fetchBySource(AnnouncementSource.daily, limit: limit),
        _fetchBySource(AnnouncementSource.authority, limit: limit),
        _fetchBySource(AnnouncementSource.app, limit: limit),
      ]);

      final merged = chunks.expand((chunk) => chunk).toList(growable: false);
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    }

    return _fetchBySource(source, limit: limit);
  }

  Future<List<AnnouncementModel>> _fetchBySource(
    AnnouncementSource source, {
    required int limit,
  }) async {
    final type = _toApiType(source);

    int? wardId;
    if (source == AnnouncementSource.authority) {
      final profile = await _profileRepository.getProfile();
      wardId = profile.residenceWardCode;

      // Business decision: no ward means empty authority announcements.
      if (wardId == null) {
        return const <AnnouncementModel>[];
      }
    }

    final response = await _authorityService.getPublicAnnouncements(
      type: type,
      limit: limit,
      wardId: wardId,
    );

    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final rawItems = data['items'] as List<dynamic>? ?? const <dynamic>[];

    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(AnnouncementModel.fromJson)
        .map(_applyReadState)
        .toList(growable: false);

    for (final item in items) {
      _cache[item.id] = item;
    }

    return items;
  }

  @override
  Future<AnnouncementModel?> getAnnouncementById(String announcementId) async {
    final cached = _cache[announcementId];
    if (cached != null) {
      return _applyReadState(cached);
    }

    final all = await getAnnouncements(limit: 50);
    for (final item in all) {
      if (item.id == announcementId) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<bool> markAsRead(String announcementId) async {
    _readIds.add(announcementId);

    final cached = _cache[announcementId];
    if (cached != null) {
      _cache[announcementId] = cached.copyWith(isRead: true);
    }

    return true;
  }

  @override
  Future<int> getUnreadCount({AnnouncementSource? source}) async {
    final announcements = await getAnnouncements(source: source);
    return announcements.where((item) => !item.isRead).length;
  }

  String _toApiType(AnnouncementSource source) {
    switch (source) {
      case AnnouncementSource.daily:
        return 'DAILY';
      case AnnouncementSource.authority:
        return 'AUTHORITY';
      case AnnouncementSource.app:
        return 'APP';
    }
  }

  AnnouncementModel _applyReadState(AnnouncementModel item) {
    final isRead = _readIds.contains(item.id) || item.isRead;
    return item.copyWith(isRead: isRead);
  }
}
