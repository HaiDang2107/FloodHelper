import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final existing = await _repository.getExistingCampaigns();
      final mine = await _repository.getMyCampaigns();
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

  Future<void> createCampaign(CharityCampaign campaign) async {
    try {
      final created = await _repository.createMyCampaign(campaign);
      state = state.copyWith(myCampaigns: [created, ...state.myCampaigns]);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create campaign: $e');
    }
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

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
