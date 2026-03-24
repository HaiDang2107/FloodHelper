import '../../models/authority/authority_profile.dart';
import '../../models/authority/role_request.dart';
import '../../mappers/authority_mappers.dart';
import '../../services/authority_service.dart';
import '../../services/auth_local_storage.dart';
import '../authority_repository.dart';

class RealAuthorityRepository implements AuthorityRepository {
  final AuthorityService _authorityService;

  RealAuthorityRepository({required AuthorityService authorityService})
      : _authorityService = authorityService;

  @override
  Future<AuthorityProfile?> fetchProfileFromSession() async {
    final userData = await AuthLocalStorage.getUserData();
    if (userData == null) {
      return null;
    }

    return AuthorityMappers.profileFromSession(userData);
  }

  @override
  Future<AuthorityRoleRequestPage> fetchRoleRequests({
    String? beforeCreatedAt,
  }) async {
    final body = await _authorityService.getRoleRequests(
      beforeCreatedAt: beforeCreatedAt,
    );
    final list = (body['data'] as List<dynamic>? ?? const []);
    final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

    final items = list
        .whereType<Map<String, dynamic>>()
        .map(AuthorityMappers.roleRequestFromApi)
        .toList();

    return AuthorityRoleRequestPage(
      items: items,
      hasMore: pagination['hasMore'] == true,
      nextCursor: pagination['nextCursor']?.toString(),
    );
  }

  @override
  Future<RoleRequest> approveRoleRequest(String requestId, {String? note}) async {
    final body = await _authorityService.approveRoleRequest(
      requestId,
      note: note,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.roleRequestFromApi(data);
  }

  @override
  Future<RoleRequest> rejectRoleRequest(String requestId, {String? note}) async {
    final body = await _authorityService.rejectRoleRequest(
      requestId,
      note: note,
    );
    final data = body['data'] as Map<String, dynamic>? ?? {};
    return AuthorityMappers.roleRequestFromApi(data);
  }
}
