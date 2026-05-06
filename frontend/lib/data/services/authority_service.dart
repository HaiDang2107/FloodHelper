import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

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

  Future<Map<String, dynamic>> getAuthorityAnnouncements({
    String? beforeCreatedAt,
    int limit = 10,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (beforeCreatedAt != null) {
      query['beforeCreatedAt'] = beforeCreatedAt;
    }

    final response = await _apiClient.get(
      '/announcements/authority',
      queryParameters: query,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getPublicAnnouncements({
    required String type,
    String? beforeCreatedAt,
    int limit = 20,
    int? wardId,
  }) async {
    final query = <String, dynamic>{
      'type': type,
      'limit': limit,
    };

    if (beforeCreatedAt != null) {
      query['beforeCreatedAt'] = beforeCreatedAt;
    }

    if (wardId != null) {
      query['wardId'] = wardId;
    }

    final response = await _apiClient.get(
      '/announcements/public',
      queryParameters: query,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getAuthorityAnnouncementDetail(
    String announcementId,
  ) async {
    final response = await _apiClient.get('/announcements/authority/$announcementId');
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> publishAuthorityAnnouncement({
    required String title,
    required String caption,
    Uint8List? bytes,
    String? fileName,
    String? mimeType,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'caption': caption,
    };

    if (bytes != null && fileName != null && mimeType != null) {
      formMap['file'] = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
    }

    final response = await _apiClient.post(
      '/announcements/authority',
      data: FormData.fromMap(formMap),
      onSendProgress: onSendProgress,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> deleteAuthorityAnnouncement(
    String announcementId,
  ) async {
    final response = await _apiClient.delete(
      '/announcements/authority/$announcementId',
    );
    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getProfileUpdateRequests({
    String? beforeCreatedAt,
    String? type,
    String? state,
  }) async {
    final query = <String, dynamic>{};
    if (beforeCreatedAt != null) {
      query['beforeCreatedAt'] = beforeCreatedAt;
    }
    if (type != null) {
      query['type'] = type;
    }
    if (state != null) {
      query['state'] = state;
    }

    final response = await _apiClient.get(
      '/user/authority/profile-update-requests',
      queryParameters: query,
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> approveProfileUpdateRequest(
    String requestId, {
    String? note,
  }) async {
    final response = await _apiClient.patch(
      '/user/authority/profile-update-requests/$requestId/approve',
      data: {
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> rejectProfileUpdateRequest(
    String requestId, {
    String? note,
  }) async {
    final response = await _apiClient.patch(
      '/user/authority/profile-update-requests/$requestId/reject',
      data: {
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );

    return response.data as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}