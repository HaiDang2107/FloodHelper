import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/authority/profile_update_request.dart';
import '../../../data/models/authority/role_request.dart';
import '../../../data/providers/authority_providers.dart';

part 'profile_update_requests_view_model.g.dart';

class ProfileUpdateRequestsState {
  const ProfileUpdateRequestsState({
    this.allRequests = const [],
    this.requests = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.statusFilter,
    this.roleFilter,
    this.selectedId,
    this.nextCursor,
    this.hasMore = true,
    this.endMessage,
    this.errorMessage,
  });

  final List<AuthorityProfileUpdateRequest> allRequests;
  final List<AuthorityProfileUpdateRequest> requests;
  final bool isLoading;
  final bool isLoadingMore;
  final RoleRequestStatus? statusFilter;
  final RoleRequestType? roleFilter;
  final String? selectedId;
  final String? nextCursor;
  final bool hasMore;
  final String? endMessage;
  final String? errorMessage;

  ProfileUpdateRequestsState copyWith({
    List<AuthorityProfileUpdateRequest>? allRequests,
    List<AuthorityProfileUpdateRequest>? requests,
    bool? isLoading,
    bool? isLoadingMore,
    RoleRequestStatus? statusFilter,
    bool clearStatusFilter = false,
    RoleRequestType? roleFilter,
    bool clearRoleFilter = false,
    String? selectedId,
    String? nextCursor,
    bool? hasMore,
    String? endMessage,
    bool clearEndMessage = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileUpdateRequestsState(
      allRequests: allRequests ?? this.allRequests,
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      selectedId: selectedId ?? this.selectedId,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      endMessage: clearEndMessage ? null : (endMessage ?? this.endMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  AuthorityProfileUpdateRequest? get selectedRequest {
    if (selectedId == null || requests.isEmpty) {
      return null;
    }
    return requests.firstWhere(
      (request) => request.id == selectedId,
      orElse: () => requests.first,
    );
  }
}

@riverpod
class ProfileUpdateRequestsViewModel extends _$ProfileUpdateRequestsViewModel {
  @override
  ProfileUpdateRequestsState build() {
    return const ProfileUpdateRequestsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearEndMessage: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchProfileUpdateRequests(
        statusFilter: state.statusFilter,
        roleFilter: state.roleFilter,
      );

      final allData = page.items;
      final filtered = _applyFilters(allData);

      state = state.copyWith(
        allRequests: allData,
        requests: filtered,
        isLoading: false,
        selectedId: filtered.isNotEmpty ? filtered.first.id : null,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: filtered.isEmpty ? 'No requests to review.' : null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile update requests: $error',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearEndMessage: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final page = await repository.fetchProfileUpdateRequests(
        beforeCreatedAt: state.nextCursor,
        statusFilter: state.statusFilter,
        roleFilter: state.roleFilter,
      );

      final mergedAll = [...state.allRequests, ...page.items];
      final filtered = _applyFilters(mergedAll);
      state = state.copyWith(
        allRequests: mergedAll,
        requests: filtered,
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        endMessage: page.hasMore ? null : 'No more requests.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Failed to load more profile update requests: $error',
      );
    }
  }

  Future<void> setStatusFilter(RoleRequestStatus? status) async {
    if (status == null) {
      state = const ProfileUpdateRequestsState();
      return;
    }

    final nextState = state.copyWith(statusFilter: status);
    final isSameFilter = state.statusFilter == status;

    state = nextState;
    if (nextState.allRequests.isEmpty || !isSameFilter) {
      await load();
      return;
    }

    final filtered = _applyFilters(nextState.allRequests, state: nextState);
    state = state.copyWith(
      requests: filtered,
      selectedId: _resolveSelectedId(filtered, nextState.selectedId),
      endMessage: filtered.isEmpty ? 'No requests match this filter.' : null,
    );
  }

  Future<void> setRoleFilter(RoleRequestType? roleType) async {
    final nextState = roleType == null
        ? state.copyWith(
            clearRoleFilter: true,
          )
        : state.copyWith(
            roleFilter: roleType,
          );

    state = nextState;
    if (nextState.allRequests.isEmpty) {
      await load();
      return;
    }

    final filtered = _applyFilters(nextState.allRequests, state: nextState);
    state = state.copyWith(
      requests: filtered,
      selectedId: _resolveSelectedId(filtered, nextState.selectedId),
      endMessage: filtered.isEmpty ? 'No requests match this filter.' : null,
    );
  }

  void selectRequest(String id) {
    state = state.copyWith(selectedId: id);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> approveSelected({String? note}) async {
    final request = state.selectedRequest;
    if (request == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      await repository.approveProfileUpdateRequest(request.id, note: note);
      _replaceRequest(request.id, request.copyWith(
        status: RoleRequestStatus.approved,
        notes: note ?? request.notes,
        respondedAt: DateTime.now(),
      ));
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to approve profile update request: $error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectSelected({String? note}) async {
    final request = state.selectedRequest;
    if (request == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      await repository.rejectProfileUpdateRequest(request.id, note: note);
      _replaceRequest(request.id, request.copyWith(
        status: RoleRequestStatus.rejected,
        notes: note ?? request.notes,
        respondedAt: DateTime.now(),
      ));
    } catch (error) {
      state = state.copyWith(errorMessage: 'Failed to reject profile update request: $error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _replaceRequest(String id, AuthorityProfileUpdateRequest updated) {
    final nextAll = state.allRequests
        .map((request) => request.id == id ? updated : request)
        .toList();

    final filtered = _applyFilters(nextAll);

    state = state.copyWith(
      allRequests: nextAll,
      requests: filtered,
      selectedId: _resolveSelectedId(filtered, state.selectedId),
    );
  }

  List<AuthorityProfileUpdateRequest> _applyFilters(
    List<AuthorityProfileUpdateRequest> source, {
    ProfileUpdateRequestsState? state,
  }) {
    final currentState = state ?? this.state;
    return source.where((request) {
      final matchStatus = currentState.statusFilter == null ||
          request.status == currentState.statusFilter;
      final matchRole = currentState.roleFilter == null ||
          request.requesterRole == currentState.roleFilter;
      return matchStatus && matchRole;
    }).toList();
  }

  String? _resolveSelectedId(List<AuthorityProfileUpdateRequest> filtered, String? currentSelectedId) {
    if (filtered.isEmpty) {
      return null;
    }
    final hasSelected = currentSelectedId != null &&
        filtered.any((request) => request.id == currentSelectedId);
    return hasSelected ? currentSelectedId : filtered.first.id;
  }
}
