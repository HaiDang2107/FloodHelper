import 'api_client.dart';

class AuthorityService {
  final ApiClient _apiClient;

  AuthorityService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getRoleRequests({
    String? beforeCreatedAt,
  }) async {
    final query = <String, dynamic>{};
    if (beforeCreatedAt != null) {
      query['beforeCreatedAt'] = beforeCreatedAt;
    }

    final response = await _apiClient.get(
      '/authority/role-requests',
      queryParameters: query,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> approveRoleRequest(
    String requestId, {
    String? note,
  }) async {
    final response = await _apiClient.patch(
      '/authority/role-requests/$requestId/approve',
      data: {
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> rejectRoleRequest(
    String requestId, {
    String? note,
  }) async {
    final response = await _apiClient.patch(
      '/authority/role-requests/$requestId/reject',
      data: {
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}