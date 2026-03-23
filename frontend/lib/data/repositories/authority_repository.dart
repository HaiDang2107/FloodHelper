import '../models/authority/authority_profile.dart';
import '../models/authority/role_request.dart';

abstract class AuthorityRepository {
  Future<bool> signIn(String email, String password);

  Future<AuthorityProfile> fetchProfile();

  Future<List<RoleRequest>> fetchRoleRequests({
    RoleRequestStatus? status,
    RoleRequestType? requestedRole,
  });
}
