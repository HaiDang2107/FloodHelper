import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/profile_model.dart';

/// Service for profile API calls
class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get current user's profile
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get('/user/profile');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update current user's profile
  Future<ProfileModel> updateProfile(UpdateProfileDto dto) async {
    try {
      final response = await _apiClient.patch(
        '/user/profile',
        data: dto.toJson(),
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update current user's location
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
    bool? publicMapMode,
  }) async {
    try {
      await _apiClient.patch(
        '/user/location',
        data: {
          'curLongitude': longitude,
          'curLatitude': latitude,
          if (publicMapMode != null) 'publicMapMode': publicMapMode,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get user by ID (public profile)
  Future<ProfileModel?> getUserById(String userId) async {
    try {
      final response = await _apiClient.get('/user/$userId');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      // Return null if user not found
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException.fromDioError(e);
    }
  }
}
