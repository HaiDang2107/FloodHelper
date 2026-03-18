import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/friend_request_model.dart';
import '../models/friend_model.dart';

/// Service for friend API calls
class FriendService {
  final ApiClient _apiClient;

  FriendService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Send a friend request
  Future<SendFriendRequestResponse> sendFriendRequest({
    required String receiverId,
    String? note,
  }) async {
    try {
      final response = await _apiClient.post(
        '/friend/request',
        data: {
          'receiverId': receiverId,
          if (note case final String n) 'note': n,
        },
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return SendFriendRequestResponse.fromJson(data['data']);
      }
      throw ApiException(
        message: data['message'] ?? 'Failed to send friend request',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get all sent friend requests
  Future<List<FriendRequestModel>> getSentRequests() async {
    try {
      final response = await _apiClient.get('/friend/requests/sent');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((json) => FriendRequestModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get all received friend requests
  Future<List<FriendRequestModel>> getReceivedRequests() async {
    try {
      final response = await _apiClient.get('/friend/requests/received');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((json) => FriendRequestModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _apiClient.patch('/friend/request/$requestId/accept');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Reject a friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _apiClient.patch('/friend/request/$requestId/reject');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cancel a sent friend request
  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _apiClient.delete('/friend/request/$requestId');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiClient.patch(
        '/friend/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get all friends with map mode status
  Future<List<FriendModel>> getFriends() async {
    try {
      final response = await _apiClient.get('/friend/list');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((json) => FriendModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Batch-update friendMapMode for multiple friends
  Future<void> updateFriendMapModes({
    required List<String> friendIds,
    required bool mapMode,
  }) async {
    try {
      await _apiClient.patch(
        '/friend/map-mode',
        data: {
          'friendIds': friendIds,
          'mapMode': mapMode,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
