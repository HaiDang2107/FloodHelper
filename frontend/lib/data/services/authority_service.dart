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

  Future<Map<String, dynamic>> getCharityCampaignRequests({
    String? beforeRequestedAt,
    String? state,
  }) async {
    final query = <String, dynamic>{};
    if (beforeRequestedAt != null) {
      query['beforeRequestedAt'] = beforeRequestedAt;
    }
    if (state != null) {
      query['state'] = state;
    }

    final response = await _apiClient.get(
      '/authority/campaigns',
      queryParameters: query,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getCharityCampaignDetail(String campaignId) async {
    final response = await _apiClient.get('/authority/campaigns/$campaignId');
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> approveCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  }) async {
    final response = await _apiClient.patch(
      '/authority/campaigns/$campaignId/approve',
      data: {
        if (noteForResponse != null && noteForResponse.trim().isNotEmpty)
          'noteForResponse': noteForResponse.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> rejectCharityCampaign(
    String campaignId, {
    String? noteForResponse,
  }) async {
    final response = await _apiClient.patch(
      '/authority/campaigns/$campaignId/reject',
      data: {
        if (noteForResponse != null && noteForResponse.trim().isNotEmpty)
          'noteForResponse': noteForResponse.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> suspendCharityCampaign(
    String campaignId, {
    String? noteForSuspension,
  }) async {
    final response = await _apiClient.patch(
      '/authority/campaigns/$campaignId/suspend',
      data: {
        if (noteForSuspension != null && noteForSuspension.trim().isNotEmpty)
          'noteForSuspension': noteForSuspension.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}