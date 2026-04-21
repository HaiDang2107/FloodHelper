import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user_model.dart';

/// Service for user-related API calls
class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/user/profile');
      final data = response.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get nearby users
  Future<List<UserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/user/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusKm,
        },
      );
      final data = response.data;

      if (data is List) {
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get current visibility mode from backend
  Future<String> getVisibility() async {
    try {
      final response = await _apiClient.get('/user/visibility');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return data['data']['visibility'] as String? ?? 'PUBLIC';
      }
      return 'PUBLIC';
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update location visibility (PUBLIC / JUST_FRIEND / NO_ONE)
  Future<void> updateVisibility(String visibility) async {
    try {
      await _apiClient.patch(
        '/user/visibility',
        data: {'visibility': visibility},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateShowCharityCampaignLocations(bool value) async {
    try {
      await _apiClient.patch(
        '/user/profile',
        data: {'showCharityCampaignLocations': value},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update user location
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _apiClient.patch(
        '/user/location',
        data: {
          'curLongitude': longitude,
          'curLatitude': latitude,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
