import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/authority/role_request.dart';
import '../../../data/providers/authority_providers.dart';

part 'role_requests_view_model.g.dart';

class RoleRequestsState {
  const RoleRequestsState({
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
  });

  final List<RoleRequest> allRequests;
  final List<RoleRequest> requests;
  final bool isLoading;
  final bool isLoadingMore;
  final RoleRequestStatus? statusFilter;
  final RoleRequestType? roleFilter;
  final String? selectedId;
  final String? nextCursor;
  final bool hasMore;
  final String? endMessage;

  RoleRequestsState copyWith({
    List<RoleRequest>? allRequests,
    List<RoleRequest>? requests,
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
  }) {
    return RoleRequestsState(
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
    );
  }

  RoleRequest? get selectedRequest {
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
class RoleRequestsViewModel extends _$RoleRequestsViewModel {
  @override
  RoleRequestsState build() {
    return const RoleRequestsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearEndMessage: true);
    final repository = ref.read(authorityRepositoryProvider);
    final page = await repository.fetchRoleRequests();

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
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearEndMessage: true);
    final repository = ref.read(authorityRepositoryProvider);
    final page = await repository.fetchRoleRequests(
      beforeCreatedAt: state.nextCursor,
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
  }

  Future<void> setStatusFilter(RoleRequestStatus? status) async {
    final nextState = status == null
        ? state.copyWith(
            clearStatusFilter: true,
          )
        : state.copyWith(
            statusFilter: status,
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

  Future<void> approveSelected({String? note}) async {
    final request = state.selectedRequest;
    if (request == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final updated = await repository.approveRoleRequest(request.id, note: note);
      _replaceRequest(request.id, request.copyWith(
        status: RoleRequestStatus.approved,
        notes: updated.notes,
        respondedAt: updated.respondedAt ?? DateTime.now(),
      ));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectSelected({String? note}) async {
    final request = state.selectedRequest;
    if (request == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(authorityRepositoryProvider);
      final updated = await repository.rejectRoleRequest(request.id, note: note);
      _replaceRequest(request.id, request.copyWith(
        status: RoleRequestStatus.rejected,
        notes: updated.notes,
        respondedAt: updated.respondedAt ?? DateTime.now(),
      ));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _replaceRequest(String id, RoleRequest updated) {
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

  List<RoleRequest> _applyFilters(
    List<RoleRequest> source, {
    RoleRequestsState? state,
  }) {
    final currentState = state ?? this.state;
    return source.where((request) {
      final matchStatus = currentState.statusFilter == null ||
          request.status == currentState.statusFilter;
      final matchRole = currentState.roleFilter == null ||
          request.requestedRole == currentState.roleFilter;
      return matchStatus && matchRole;
    }).toList();
  }

  String? _resolveSelectedId(List<RoleRequest> filtered, String? currentSelectedId) {
    if (filtered.isEmpty) {
      return null;
    }
    final hasSelected = currentSelectedId != null &&
        filtered.any((request) => request.id == currentSelectedId);
    return hasSelected ? currentSelectedId : filtered.first.id;
  }
}
