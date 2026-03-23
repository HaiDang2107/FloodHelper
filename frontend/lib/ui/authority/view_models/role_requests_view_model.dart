import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/authority/role_request.dart';
import '../../../data/providers/authority_providers.dart';

part 'role_requests_view_model.g.dart';

class RoleRequestsState {
  const RoleRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.statusFilter,
    this.roleFilter,
    this.selectedId,
  });

  final List<RoleRequest> requests;
  final bool isLoading;
  final RoleRequestStatus? statusFilter;
  final RoleRequestType? roleFilter;
  final String? selectedId;

  RoleRequestsState copyWith({
    List<RoleRequest>? requests,
    bool? isLoading,
    RoleRequestStatus? statusFilter,
    bool clearStatusFilter = false,
    RoleRequestType? roleFilter,
    bool clearRoleFilter = false,
    String? selectedId,
  }) {
    return RoleRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      selectedId: selectedId ?? this.selectedId,
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
    state = state.copyWith(isLoading: true);
    final repository = ref.read(authorityRepositoryProvider);
    final data = await repository.fetchRoleRequests(
      status: state.statusFilter,
      requestedRole: state.roleFilter,
    );
    state = state.copyWith(
      requests: data,
      isLoading: false,
      selectedId: data.isNotEmpty ? data.first.id : null,
    );
  }

  Future<void> setStatusFilter(RoleRequestStatus? status) async {
    state = status == null
        ? state.copyWith(clearStatusFilter: true, selectedId: null)
        : state.copyWith(statusFilter: status, selectedId: null);
    await load();
  }

  Future<void> setRoleFilter(RoleRequestType? roleType) async {
    state = roleType == null
        ? state.copyWith(clearRoleFilter: true, selectedId: null)
        : state.copyWith(roleFilter: roleType, selectedId: null);
    await load();
  }

  void selectRequest(String id) {
    state = state.copyWith(selectedId: id);
  }
}
