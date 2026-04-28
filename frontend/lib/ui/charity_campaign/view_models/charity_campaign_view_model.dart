import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/global_session_provider.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/charity_campaign_repository.dart';
import '../../../domain/models/charity_campaign.dart';

part 'charity_campaign_view_model.g.dart';

class CharityCampaignState {
  final bool isLoading;
  final String? errorMessage;
  final List<CharityCampaign> existingCampaigns;
  final List<CharityCampaign> myCampaigns;
  final Map<String, List<CampaignAnnouncement>> campaignAnnouncements;
  final Map<String, bool> campaignAnnouncementsHasMore;
  final Map<String, String?> campaignAnnouncementsNextCursor;
  final Set<String> loadingAnnouncementCampaignIds;
  final Set<String> loadingMoreAnnouncementCampaignIds;
  final Set<CampaignStatus> loadedExistingStatuses;
  final Set<CampaignStatus> loadedMyStatuses;
  final Set<CampaignStatus> loadingExistingStatuses;
  final Set<CampaignStatus> loadingMyStatuses;

  const CharityCampaignState({
    this.isLoading = false,
    this.errorMessage,
    this.existingCampaigns = const [],
    this.myCampaigns = const [],
    this.campaignAnnouncements = const <String, List<CampaignAnnouncement>>{},
    this.campaignAnnouncementsHasMore = const <String, bool>{},
    this.campaignAnnouncementsNextCursor = const <String, String?>{},
    this.loadingAnnouncementCampaignIds = const <String>{},
    this.loadingMoreAnnouncementCampaignIds = const <String>{},
    this.loadedExistingStatuses = const <CampaignStatus>{},
    this.loadedMyStatuses = const <CampaignStatus>{},
    this.loadingExistingStatuses = const <CampaignStatus>{},
    this.loadingMyStatuses = const <CampaignStatus>{},
  });

  CharityCampaignState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CharityCampaign>? existingCampaigns,
    List<CharityCampaign>? myCampaigns,
    Map<String, List<CampaignAnnouncement>>? campaignAnnouncements,
    Map<String, bool>? campaignAnnouncementsHasMore,
    Map<String, String?>? campaignAnnouncementsNextCursor,
    Set<String>? loadingAnnouncementCampaignIds,
    Set<String>? loadingMoreAnnouncementCampaignIds,
    Set<CampaignStatus>? loadedExistingStatuses,
    Set<CampaignStatus>? loadedMyStatuses,
    Set<CampaignStatus>? loadingExistingStatuses,
    Set<CampaignStatus>? loadingMyStatuses,
    bool clearError = false,
  }) {
    return CharityCampaignState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      existingCampaigns: existingCampaigns ?? this.existingCampaigns,
      myCampaigns: myCampaigns ?? this.myCampaigns,
        campaignAnnouncements:
          campaignAnnouncements ?? this.campaignAnnouncements,
        campaignAnnouncementsHasMore:
          campaignAnnouncementsHasMore ?? this.campaignAnnouncementsHasMore,
        campaignAnnouncementsNextCursor:
          campaignAnnouncementsNextCursor ?? this.campaignAnnouncementsNextCursor,
        loadingAnnouncementCampaignIds:
          loadingAnnouncementCampaignIds ?? this.loadingAnnouncementCampaignIds,
        loadingMoreAnnouncementCampaignIds:
          loadingMoreAnnouncementCampaignIds ?? this.loadingMoreAnnouncementCampaignIds,
      loadedExistingStatuses:
          loadedExistingStatuses ?? this.loadedExistingStatuses,
      loadedMyStatuses: loadedMyStatuses ?? this.loadedMyStatuses,
      loadingExistingStatuses:
          loadingExistingStatuses ?? this.loadingExistingStatuses,
      loadingMyStatuses: loadingMyStatuses ?? this.loadingMyStatuses,
    );
  }
}

@riverpod
class CharityCampaignViewModel extends _$CharityCampaignViewModel {
  late final CharityCampaignRepository _repository = ref.read(
    charityCampaignRepositoryProvider,
  );

  @override
  CharityCampaignState build() {
    return const CharityCampaignState();
  }

  Future<void> ensureExistingStatusLoaded(CampaignStatus status) async {
    if (state.loadedExistingStatuses.contains(status)) {
      return;
    }
    await _loadExistingStatus(status, force: false);
  }

  Future<void> refreshExistingStatus(CampaignStatus status) async {
    await _loadExistingStatus(status, force: true);
  }

  Future<void> ensureMyStatusLoaded(CampaignStatus status) async {
    if (state.loadedMyStatuses.contains(status)) {
      return;
    }
    await _loadMyStatus(status, force: false);
  }

  Future<void> refreshMyStatus(CampaignStatus status) async {
    await _loadMyStatus(status, force: true);
  }

  bool isExistingStatusLoading(CampaignStatus status) {
    return state.loadingExistingStatuses.contains(status);
  }

  bool isMyStatusLoading(CampaignStatus status) {
    return state.loadingMyStatuses.contains(status);
  }

  Future<void> _loadExistingStatus(
    CampaignStatus status, {
    required bool force,
  }) async {
    if (!force && state.loadedExistingStatuses.contains(status)) {
      return;
    }
    if (state.loadingExistingStatuses.contains(status)) {
      return;
    }

    state = state.copyWith(
      clearError: true,
      loadingExistingStatuses: {
        ...state.loadingExistingStatuses,
        status,
      },
    );

    try {
      final campaigns = await _repository.getExistingCampaigns(status: status);
      final sorted = _sortCampaignsByStatus(campaigns, status);
      state = state.copyWith(
        existingCampaigns: _replaceStatusCampaigns(
          source: state.existingCampaigns,
          status: status,
          replacement: sorted,
        ),
        loadedExistingStatuses: {
          ...state.loadedExistingStatuses,
          status,
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load campaigns: $e',
      );
    } finally {
      final nextLoading = {...state.loadingExistingStatuses};
      nextLoading.remove(status);
      state = state.copyWith(
        loadingExistingStatuses: nextLoading,
      );
    }
  }

  Future<void> _loadMyStatus(
    CampaignStatus status, {
    required bool force,
  }) async {
    final currentUser = ref.read(currentUserProvider);
    final isBenefactor = currentUser?.isBenefactor ?? false;
    if (!isBenefactor) {
      return;
    }
    if (!force && state.loadedMyStatuses.contains(status)) {
      return;
    }
    if (state.loadingMyStatuses.contains(status)) {
      return;
    }

    state = state.copyWith(
      clearError: true,
      loadingMyStatuses: {
        ...state.loadingMyStatuses,
        status,
      },
    );

    try {
      final campaigns = await _repository.getMyCampaigns(status: status);
      final sorted = _sortCampaignsByStatus(campaigns, status);
      state = state.copyWith(
        myCampaigns: _replaceStatusCampaigns(
          source: state.myCampaigns,
          status: status,
          replacement: sorted,
        ),
        loadedMyStatuses: {
          ...state.loadedMyStatuses,
          status,
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load campaigns: $e',
      );
    } finally {
      final nextLoading = {...state.loadingMyStatuses};
      nextLoading.remove(status);
      state = state.copyWith(
        loadingMyStatuses: nextLoading,
      );
    }
  }

  Future<void> createCampaign(CharityCampaign campaign) async {
    try {
      final created = await _repository.createMyCampaign(campaign);
      _upsertMineCampaign(created);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create campaign: $e');
    }
  }

  Future<void> updateCampaign(CharityCampaign campaign) async {
    try {
      final updated = await _repository.updateMyCampaign(campaign);
      _upsertMineCampaign(updated);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update campaign: $e');
    }
  }

  Future<void> sendCampaignRequest(String campaignId) async {
    try {
      final updated = await _repository.sendCampaignRequest(campaignId);
      _upsertMineCampaign(updated);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send campaign request: $e',
      );
      rethrow;
    }
  }

  Future<DonateQrResult> createDonateQr({
    required String campaignId,
    required BigInt amount,
  }) async {
    try {
      final result = await _repository.createDonateQr(
        campaignId: campaignId,
        amount: amount,
      );
      state = state.copyWith(clearError: true);
      return result;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create VietQR: $e',
      );
      rethrow;
    }
  }

  Future<String> triggerDonateTestCallback({
    required String transactionId,
  }) async {
    try {
      final callbackState = await _repository.triggerDonateTestCallback(
        transactionId: transactionId,
      );
      state = state.copyWith(clearError: true);
      return callbackState;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to trigger callback: $e',
      );
      rethrow;
    }
  }

  Future<List<Donation>> loadSuccessTransactions(String campaignId) async {
    try {
      return await _repository.getCampaignTransactions(
        campaignId: campaignId,
        state: 'SUCCESS',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load transactions: $e',
      );
      rethrow;
    }
  }

  List<CampaignAnnouncement> announcementsForCampaign(String campaignId) {
    return state.campaignAnnouncements[campaignId] ?? const [];
  }

  bool isAnnouncementsLoading(String campaignId) {
    return state.loadingAnnouncementCampaignIds.contains(campaignId);
  }

  bool isAnnouncementsLoadingMore(String campaignId) {
    return state.loadingMoreAnnouncementCampaignIds.contains(campaignId);
  }

  bool hasMoreAnnouncements(String campaignId) {
    return state.campaignAnnouncementsHasMore[campaignId] == true;
  }

  Future<void> loadInitialAnnouncements(
    String campaignId, {
    bool force = false,
  }) async { // Load 10 announcements lúc ban đầu
    if (!force && state.campaignAnnouncements.containsKey(campaignId)) {
      return;
    }
    if (state.loadingAnnouncementCampaignIds.contains(campaignId)) {
      return;
    }

    state = state.copyWith(
      clearError: true,
      loadingAnnouncementCampaignIds: {
        ...state.loadingAnnouncementCampaignIds,
        campaignId,
      },
    );

    try {
      final page = await _repository.getCampaignAnnouncements(
        campaignId: campaignId,
        limit: 10,
      );

      state = state.copyWith(
        campaignAnnouncements: {
          ...state.campaignAnnouncements,
          campaignId: page.items,
        },
        campaignAnnouncementsHasMore: {
          ...state.campaignAnnouncementsHasMore,
          campaignId: page.hasMore,
        },
        campaignAnnouncementsNextCursor: {
          ...state.campaignAnnouncementsNextCursor,
          campaignId: page.nextCursor,
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load announcements: $e',
      );
    } finally {
      final nextLoading = {...state.loadingAnnouncementCampaignIds};
      nextLoading.remove(campaignId);
      state = state.copyWith(
        loadingAnnouncementCampaignIds: nextLoading,
      );
    }
  }

  Future<void> loadMoreAnnouncements(String campaignId) async { // Load thêm 10 announcements
    if (state.loadingAnnouncementCampaignIds.contains(campaignId) ||
        state.loadingMoreAnnouncementCampaignIds.contains(campaignId) ||
        !hasMoreAnnouncements(campaignId)) {
      return;
    }

    final cursor = state.campaignAnnouncementsNextCursor[campaignId];
    if (cursor == null || cursor.isEmpty) {
      return;
    }

    state = state.copyWith(
      clearError: true,
      loadingMoreAnnouncementCampaignIds: {
        ...state.loadingMoreAnnouncementCampaignIds,
        campaignId,
      },
    );

    try {
      final page = await _repository.getCampaignAnnouncements(
        campaignId: campaignId,
        limit: 10,
        beforePostedAt: cursor,
      );

      final current = state.campaignAnnouncements[campaignId] ?? const [];
      final merged = _mergeAnnouncements(current, page.items);

      state = state.copyWith(
        campaignAnnouncements: {
          ...state.campaignAnnouncements,
          campaignId: merged,
        },
        campaignAnnouncementsHasMore: {
          ...state.campaignAnnouncementsHasMore,
          campaignId: page.hasMore,
        },
        campaignAnnouncementsNextCursor: {
          ...state.campaignAnnouncementsNextCursor,
          campaignId: page.nextCursor,
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load more announcements: $e',
      );
    } finally {
      final nextLoadingMore = {...state.loadingMoreAnnouncementCampaignIds};
      nextLoadingMore.remove(campaignId);
      state = state.copyWith(
        loadingMoreAnnouncementCampaignIds: nextLoadingMore,
      );
    }
  }

  Future<CharityCampaign> loadCampaignDetail(String campaignId) async {
    final detail = await _repository.getCampaignDetail(campaignId);

    List<CharityCampaign> replaceIfMatch(List<CharityCampaign> source) {
      return source
          .map((campaign) => campaign.id == campaignId ? detail : campaign)
          .toList(growable: false);
    }

    state = state.copyWith(
      existingCampaigns: replaceIfMatch(state.existingCampaigns),
      myCampaigns: replaceIfMatch(state.myCampaigns),
    );

    return detail;
  }

  Future<CharityCampaign> uploadBankStatement({
    required String campaignId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final updated = await _repository.uploadCampaignBankStatement(
        campaignId: campaignId,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        onSendProgress: onSendProgress,
      );

      _replaceCampaignDetail(updated);
      return updated;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to upload bank statement: $e',
      );
      rethrow;
    }
  }

  Future<CharityCampaign> deleteBankStatement(String campaignId) async {
    try {
      final updated = await _repository.deleteCampaignBankStatement(
        campaignId: campaignId,
      );

      _replaceCampaignDetail(updated);
      return updated;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete bank statement: $e',
      );
      rethrow;
    }
  }

  Future<void> checkInCampaignLocation({
    required String campaignId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _repository.updateCampaignLocation(
        campaignId: campaignId,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(clearError: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to check in campaign location: $e',
      );
      rethrow;
    }
  }

  Future<void> postAnnouncement({
    required String campaignId,
    required String caption,
    required String imagePath,
    String? imageName,
  }) async { // post + cập nhật announcements trên UI sau khi user post thông báo
    final trimmed = caption.trim();
    if (trimmed.isEmpty) {
      return;
    }

    if (imagePath.trim().isEmpty) {
      return;
    }

    CampaignAnnouncement newAnnouncement;
    try {
      newAnnouncement = await _repository.createCampaignAnnouncement(
        campaignId: campaignId,
        caption: trimmed,
        imagePath: imagePath,
        imageName: imageName,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to post announcement: $e',
      );
      rethrow;
    }

    List<CharityCampaign> appendAnnouncement(List<CharityCampaign> source) {
      return source
          .map((campaign) {
            if (campaign.id != campaignId) {
              return campaign;
            }
            return campaign.copyWith(
              announcements: [newAnnouncement, ...campaign.announcements],
            );
          })
          .toList(growable: false);
    }

    state = state.copyWith(
      myCampaigns: appendAnnouncement(state.myCampaigns),
      existingCampaigns: appendAnnouncement(state.existingCampaigns),
      campaignAnnouncements: {
        ...state.campaignAnnouncements,
        campaignId: [
          newAnnouncement,
          ...(state.campaignAnnouncements[campaignId] ?? const []),
        ],
      },
    );
  }

  List<CampaignAnnouncement> _mergeAnnouncements(
    List<CampaignAnnouncement> current,
    List<CampaignAnnouncement> incoming,
  ) { // Dùng khi load more: gộp danh sách cũ và mới
    final seen = <String>{};
    final merged = <CampaignAnnouncement>[];

    for (final item in [...current, ...incoming]) {
      final key = '${item.text}|${item.imageUrl ?? ''}|${item.date.toIso8601String()}';
      if (seen.add(key)) {
        merged.add(item);
      }
    }

    return merged;
  }

  List<CharityCampaign> existingByStatus(CampaignStatus status) {
    return state.existingCampaigns.where((c) => c.status == status).toList();
  }

  List<CharityCampaign> mineByStatus(CampaignStatus status) {
    return state.myCampaigns.where((c) => c.status == status).toList();
  }

  List<CharityCampaign> _replaceStatusCampaigns({
    required List<CharityCampaign> source,
    required CampaignStatus status,
    required List<CharityCampaign> replacement,
  }) {
    final retained = source.where((campaign) => campaign.status != status);
    return [...retained, ...replacement];
  }

  void _upsertMineCampaign(CharityCampaign updated) {
    final retained = state.myCampaigns
        .where((campaign) => campaign.id != updated.id)
        .toList(growable: false);

    final sameStatus = [
      ...retained.where((campaign) => campaign.status == updated.status),
      updated,
    ];
    final sortedSameStatus = _sortCampaignsByStatus(sameStatus, updated.status);

    state = state.copyWith(
      myCampaigns: [
        ...retained.where((campaign) => campaign.status != updated.status),
        ...sortedSameStatus,
      ],
    );
  }

  List<CharityCampaign> _sortCampaignsByStatus(
    List<CharityCampaign> campaigns,
    CampaignStatus status,
  ) {
    final sorted = campaigns.toList(growable: false);
    sorted.sort((a, b) {
      final aDate = _statusSortDate(a, status);
      final bDate = _statusSortDate(b, status);
      final byDate = bDate.compareTo(aDate);
      if (byDate != 0) {
        return byDate;
      }
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  DateTime _statusSortDate(CharityCampaign campaign, CampaignStatus status) {
    switch (status) {
      case CampaignStatus.created:
        return campaign.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.pending:
        return campaign.requestedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.approved:
      case CampaignStatus.rejected:
        return campaign.respondedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.donating:
        return campaign.startedDonationAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.distributing:
        return campaign.startedDistributionAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.suspended:
        return campaign.respondedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      case CampaignStatus.finished:
        return campaign.finishedDistributionAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _replaceCampaignDetail(CharityCampaign updated) {
    List<CharityCampaign> replace(List<CharityCampaign> source) {
      return source
          .map((campaign) => campaign.id == updated.id ? updated : campaign)
          .toList(growable: false);
    }

    state = state.copyWith(
      existingCampaigns: replace(state.existingCampaigns),
      myCampaigns: replace(state.myCampaigns),
    );
  }
}
