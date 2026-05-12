import 'api_client.dart';
import '../models/admin/admin_dtos.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> getAdminProfile() async {
    final response = await _apiClient.get('/admin/profile');
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> searchUserByEmail(String email) async {
    final response = await _apiClient.get(
      '/admin/users/search',
      queryParameters: <String, dynamic>{'email': email},
    );
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await _apiClient.get('/admin/users/$userId');
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> createAuthority(CreateAuthorityDto dto) async {
    final response = await _apiClient.post('/admin/authorities', data: dto.toJson());
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> updateAuthority(
    String userId,
    UpdateAuthorityDto dto,
  ) async {
    final response = await _apiClient.patch(
      '/admin/authorities/$userId',
      data: dto.toJson(),
    );
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> banAccount(String userId) async {
    final response = await _apiClient.patch('/admin/users/$userId/ban');
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }

  Future<Map<String, dynamic>> unbanAccount(String userId) async {
    final response = await _apiClient.patch('/admin/users/$userId/unban');
      final body = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      return body['data'] as Map<String, dynamic>? ?? body;
  }
}
