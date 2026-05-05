import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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
  Future<ProfileModel> updateProfile(
    UpdateProfileDto dto, {
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  }) async {
    try {
      final body = dto.toJson();
        final hasFiles = avatar != null ||
          frontCitizenId != null ||
          backCitizenId != null ||
          rescuerCertificate != null;

      final data = hasFiles
          ? await _buildProfileFormData(
              body,
              avatar: avatar,
              frontCitizenId: frontCitizenId,
              backCitizenId: backCitizenId,
              rescuerCertificate: rescuerCertificate,
            )
          : body;

      final response = await _apiClient.patch('/user/profile', data: data);
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Update current user's location
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
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

  Future<void> createRoleRequest({required String type}) async {
    try {
      await _apiClient.post(
        '/user/profile/role-requests',
        data: {'type': type},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ProfileRoleRequestModel>> getMyRoleRequests() async {
    try {
      final response = await _apiClient.get('/user/profile/role-requests');
      final body = response.data as Map<String, dynamic>?;
      final data = body?['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>? ?? const []);

      return items
          .whereType<Map<String, dynamic>>()
          .map(ProfileRoleRequestModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ProfileUpdateRequestModel>> getMyProfileUpdateRequests() async {
    try {
      final response = await _apiClient.get('/user/profile/update-requests');
      final body = response.data as Map<String, dynamic>?;
      final data = body?['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>? ?? const []);

      return items
          .whereType<Map<String, dynamic>>()
          .map(ProfileUpdateRequestModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> revokeProfileUpdateRequest(String requestId) async {
    try {
      await _apiClient.patch('/user/profile/update-requests/$requestId/revoke');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createProfileUpdateRequest({
    required Map<String, dynamic> body,
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  }) async {
    try {
      final hasFiles = avatar != null ||
          frontCitizenId != null ||
          backCitizenId != null ||
          rescuerCertificate != null;

      final data = hasFiles
          ? await _buildProfileFormData(
              body,
              avatar: avatar,
              frontCitizenId: frontCitizenId,
              backCitizenId: backCitizenId,
              rescuerCertificate: rescuerCertificate,
            )
          : body;

      await _apiClient.post('/user/profile/update-requests', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> revokeRoleRequest(String requestId) async {
    try {
      await _apiClient.patch('/user/profile/role-requests/$requestId/revoke');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<FormData> _buildProfileFormData(
    Map<String, dynamic> body, {
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  }) async {
    final payload = <String, dynamic>{};

    for (final entry in body.entries) {
      payload[entry.key] = entry.value?.toString();
    }

    if (avatar != null) {
      payload['avatar'] = await MultipartFile.fromFile(
        avatar.path,
        filename: avatar.name,
      );
    }

    if (frontCitizenId != null) {
      payload['citizenFront'] = await MultipartFile.fromFile(
        frontCitizenId.path,
        filename: frontCitizenId.name,
      );
    }

    if (backCitizenId != null) {
      payload['citizenBack'] = await MultipartFile.fromFile(
        backCitizenId.path,
        filename: backCitizenId.name,
      );
    }

    if (rescuerCertificate != null) {
      payload['rescuerCertificate'] = await MultipartFile.fromFile(
        rescuerCertificate.path,
        filename: rescuerCertificate.name,
      );
    }

    return FormData.fromMap(payload);
  }
}
