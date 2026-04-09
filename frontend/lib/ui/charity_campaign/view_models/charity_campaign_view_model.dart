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

  const CharityCampaignState({
    this.isLoading = false,
    this.errorMessage,
    this.existingCampaigns = const [],
    this.myCampaigns = const [],
  });

  CharityCampaignState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CharityCampaign>? existingCampaigns,
    List<CharityCampaign>? myCampaigns,
    bool clearError = false,
  }) {
    return CharityCampaignState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      existingCampaigns: existingCampaigns ?? this.existingCampaigns,
      myCampaigns: myCampaigns ?? this.myCampaigns,
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
    Future.microtask(loadCampaigns);
    return const CharityCampaignState(isLoading: true);
  }

  Future<void> loadCampaigns() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUser = ref.read(currentUserProvider);
      final isBenefactor = currentUser?.isBenefactor ?? false;

      const existingStatuses = [
        CampaignStatus.donating,
        CampaignStatus.distributing,
        CampaignStatus.finished,
      ];

      const myStatuses = [
        CampaignStatus.created,
        CampaignStatus.pending,
        CampaignStatus.approved,
        CampaignStatus.rejected,
        CampaignStatus.donating,
        CampaignStatus.distributing,
        CampaignStatus.finished,
      ];

      final existingBatches = await Future.wait(
        existingStatuses.map(
          (status) => _repository.getExistingCampaigns(status: status),
        ),
      );

      final myBatches = await _loadMyBatchesIfBenefactor(
        isBenefactor,
        myStatuses,
      );

      final existing = existingBatches
          .expand((batch) => batch)
          .toList(growable: false);
      final mine = isBenefactor
          ? myBatches.expand((batch) => batch).toList(growable: false)
          : const <CharityCampaign>[];

      state = state.copyWith(
        isLoading: false,
        existingCampaigns: existing,
        myCampaigns: mine,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load campaigns: $e',
      );
    }
  }

  Future<List<List<CharityCampaign>>> _loadMyBatchesIfBenefactor(
    bool isBenefactor,
    List<CampaignStatus> statuses,
  ) async {
    if (!isBenefactor) {
      return const <List<CharityCampaign>>[];
    }

    return Future.wait(
      statuses.map((status) => _repository.getMyCampaigns(status: status)),
    );
  }

  Future<void> createCampaign(CharityCampaign campaign) async {
    try {
      final created = await _repository.createMyCampaign(campaign);
      state = state.copyWith(myCampaigns: [created, ...state.myCampaigns]);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create campaign: $e');
    }
  }

  Future<void> updateCampaign(CharityCampaign campaign) async {
    try {
      final updated = await _repository.updateMyCampaign(campaign);
      state = state.copyWith(myCampaigns: _replaceCampaign(state.myCampaigns, updated));
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update campaign: $e');
    }
  }

  Future<void> sendCampaignRequest(String campaignId) async {
    try {
      final updated = await _repository.sendCampaignRequest(campaignId);
      state = state.copyWith(myCampaigns: _replaceCampaign(state.myCampaigns, updated));
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send campaign request: $e',
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

  List<CharityCampaign> _replaceCampaign(
    List<CharityCampaign> source,
    CharityCampaign updated,
  ) {
    return source
        .map((campaign) => campaign.id == updated.id ? updated : campaign)
        .toList(growable: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
