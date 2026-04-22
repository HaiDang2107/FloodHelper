import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/authority_providers.dart';
import '../../../domain/models/charity_campaign.dart';

part 'charity_campaign_requests_view_model.g.dart';

class CharityCampaignRequestsState {
  const CharityCampaignRequestsState({
    this.allCampaigns = const [],
    this.campaigns = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isDetailLoading = false,
    this.statusFilter,
    this.selectedId,
    this.nextCursor,
    this.hasMore = true,
    this.endMessage,
    this.errorMessage,
  });

  final List<CharityCampaign> allCampaigns;
  final List<CharityCampaign> campaigns;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isDetailLoading;
  final CampaignStatus? statusFilter;
  final String? selectedId;
  final String? nextCursor;
  final bool hasMore;
  final String? endMessage;
  final String? errorMessage;

  CharityCampaignRequestsState copyWith({
    List<CharityCampaign>? allCampaigns,
    List<CharityCampaign>? campaigns,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDetailLoading,
    CampaignStatus? statusFilter,
    bool clearStatusFilter = false,
    String? selectedId,
    String? nextCursor,
    bool? hasMore,
    String? endMessage,
    bool clearEndMessage = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CharityCampaignRequestsState(
      allCampaigns: allCampaigns ?? this.allCampaigns,
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      selectedId: selectedId ?? this.selectedId,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      endMessage: clearEndMessage ? null : (endMessage ?? this.endMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  CharityCampaign? get selectedCampaign {
    if (selectedId == null || campaigns.isEmpty) {
      return null;
    }
    return campaigns.firstWhere(
      (campaign) => campaign.id == selectedId,
      orElse: () => campaigns.first,
    );
  }
}

@riverpod
class CharityCampaignRequestsViewModel
  extends _$CharityCampaignRequestsViewModel {
  @override
  CharityCampaignRequestsState build() {
    return const CharityCampaignRequestsState();
  }

  Future<void> load() async {
    if (state.statusFilter == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearEndMessage: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchCharityCampaignRequests(
        status: state.statusFilter,
      );

      final allData = page.items;
      final filtered = _applyFilters(allData);
      state = state.copyWith(
        allCampaigns: allData,
        campaigns: filtered,
        isLoading: false,
        selectedId: filtered.isNotEmpty ? filtered.first.id : null,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: filtered.isEmpty ? 'No campaign requests to review.' : null,
      );

      if (filtered.isNotEmpty) {
        await _hydrateDetail(filtered.first.id);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load charity requests: $error',
      );
    }
  }

  Future<void> loadMore() async {
    if (
      state.statusFilter == null ||
      state.isLoading ||
      state.isLoadingMore ||
      !state.hasMore
    ) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearEndMessage: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchCharityCampaignRequests(
        status: state.statusFilter,
        beforeRequestedAt: state.nextCursor,
      );

      final mergedAll = [...state.allCampaigns, ...page.items];
      final filtered = _applyFilters(mergedAll);
      state = state.copyWith(
        allCampaigns: mergedAll,
        campaigns: filtered,
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: page.hasMore ? null : 'No more requests.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more charity requests: $error',
      );
    }
  }

  Future<void> setStatusFilter(CampaignStatus? status) async {
    if (status == null) {
      state = const CharityCampaignRequestsState();
      return;
    }

    final isSameFilter = state.statusFilter == status;
    state = state.copyWith(statusFilter: status);

    if (state.allCampaigns.isEmpty || !isSameFilter) {
      await load();
      return;
    }

    final filtered = _applyFilters(state.allCampaigns, state: state);
    final selectedId = _resolveSelectedId(filtered, state.selectedId);
    state = state.copyWith(
      campaigns: filtered,
      selectedId: selectedId,
      endMessage: filtered.isEmpty ? 'No requests match this filter.' : null,
    );

    if (selectedId != null) {
      await _hydrateDetail(selectedId);
    }
  }

  Future<void> selectCampaign(String campaignId) async {
    state = state.copyWith(selectedId: campaignId);
    await _hydrateDetail(campaignId);
  }

  Future<void> approveSelected({String? noteByAuthority}) async {
    final campaign = state.selectedCampaign;
    if (campaign == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final updated = await repository.approveCharityCampaign(
        campaign.id,
        noteByAuthority: noteByAuthority,
      );
      _replaceCampaign(campaign.id, updated);
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to approve campaign: $error');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectSelected({String? noteByAuthority}) async {
    final campaign = state.selectedCampaign;
    if (campaign == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final updated = await repository.rejectCharityCampaign(
        campaign.id,
        noteByAuthority: noteByAuthority,
      );
      _replaceCampaign(campaign.id, updated);
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to reject campaign: $error');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> suspendSelected({String? noteByAuthority}) async {
    final campaign = state.selectedCampaign;
    if (campaign == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final updated = await repository.suspendCharityCampaign(
        campaign.id,
        noteByAuthority: noteByAuthority,
      );
      _replaceCampaign(campaign.id, updated);
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to suspend campaign: $error');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _hydrateDetail(String campaignId) async {
    state = state.copyWith(isDetailLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final detail = await repository.fetchCharityCampaignDetail(campaignId);
      _replaceCampaign(campaignId, detail);
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to load campaign detail: $error');
    } finally {
      state = state.copyWith(isDetailLoading: false);
    }
  }

  void _replaceCampaign(String id, CharityCampaign updated) {
    final nextAll = state.allCampaigns
        .map((campaign) => campaign.id == id ? updated : campaign)
        .toList(growable: false);

    final filtered = _applyFilters(nextAll);

    state = state.copyWith(
      allCampaigns: nextAll,
      campaigns: filtered,
      selectedId: _resolveSelectedId(filtered, state.selectedId),
    );
  }

  List<CharityCampaign> _applyFilters(
    List<CharityCampaign> source, {
    CharityCampaignRequestsState? state,
  }) {
    final currentState = state ?? this.state;
    if (currentState.statusFilter == null) {
      return const [];
    }

    return source.where((campaign) {
      return campaign.status == currentState.statusFilter;
    }).toList(growable: false);
  }

  String? _resolveSelectedId(
    List<CharityCampaign> filtered,
    String? currentSelectedId,
  ) {
    if (filtered.isEmpty) {
      return null;
    }
    final hasSelected = currentSelectedId != null &&
        filtered.any((campaign) => campaign.id == currentSelectedId);
    return hasSelected ? currentSelectedId : filtered.first.id;
  }
}
