import '../models/authority/authority_profile.dart';
import '../models/authority/role_request.dart';

class AuthorityRoleRequestPage {
  const AuthorityRoleRequestPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<RoleRequest> items;
  final bool hasMore;
  final String? nextCursor;
}

abstract class AuthorityRepository {
  Future<AuthorityProfile?> fetchProfileFromSession();

  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  });

  Future<RoleRequest> approveRoleRequest(String requestId, {String? note});

  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note});
}
