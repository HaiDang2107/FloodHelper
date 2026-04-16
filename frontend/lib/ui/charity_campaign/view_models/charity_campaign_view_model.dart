import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/global_session_provider.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/charity_campaign_repository.dart';
import '../../../domain/models/charity_campaign.dart';

final charityCampaignViewModelProvider =
    AutoDisposeNotifierProvider<CharityCampaignViewModel, CharityCampaignState>(
      CharityCampaignViewModel.new,
    );

class CharityCampaignState {
  final bool isLoading;
  final String? errorMessage;
  final List<CharityCampaign> existingCampaigns;
  final List<CharityCampaign> myCampaigns;
  final Set<CampaignStatus> loadedExistingStatuses;
  final Set<CampaignStatus> loadedMyStatuses;
  final Set<CampaignStatus> loadingExistingStatuses;
  final Set<CampaignStatus> loadingMyStatuses;

  const CharityCampaignState({
    this.isLoading = false,
    this.errorMessage,
    this.existingCampaigns = const [],
    this.myCampaigns = const [],
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
      loadedExistingStatuses:
          loadedExistingStatuses ?? this.loadedExistingStatuses,
      loadedMyStatuses: loadedMyStatuses ?? this.loadedMyStatuses,
      loadingExistingStatuses:
          loadingExistingStatuses ?? this.loadingExistingStatuses,
      loadingMyStatuses: loadingMyStatuses ?? this.loadingMyStatuses,
    );
  }
}

class CharityCampaignViewModel
    extends AutoDisposeNotifier<CharityCampaignState> {
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

  Future<String> createDonateQr({
    required String campaignId,
    required BigInt amount,
  }) async {
    try {
      final qrLink = await _repository.createDonateQr(
        campaignId: campaignId,
        amount: amount,
      );
      state = state.copyWith(clearError: true);
      return qrLink;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create VietQR: $e',
      );
      rethrow;
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

  Future<void> postAnnouncement({
    required String campaignId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final newAnnouncement = CampaignAnnouncement(
      text: trimmed,
      date: DateTime.now(),
    );

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
    );
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
      case CampaignStatus.finished:
        return campaign.finishedDistributionAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
