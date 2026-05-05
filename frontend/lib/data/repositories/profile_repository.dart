import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get current user's profile
  Future<ProfileModel> getProfile();
  
  /// Update current user's profile
  Future<ProfileModel> updateProfile(
    UpdateProfileDto dto, {
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  });
  
  /// Update current user's location
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  });
  
  /// Get user by ID (public profile)
  Future<ProfileModel?> getUserById(String userId);

  /// Create role request for current user (BENEFACTOR or RESCUER)
  Future<void> createRoleRequest({required String type});

  /// Get current user's submitted role requests
  Future<List<ProfileRoleRequestModel>> getMyRoleRequests();

  /// Get current user's submitted profile update requests
  Future<List<ProfileUpdateRequestModel>> getMyProfileUpdateRequests();

  /// Revoke a pending profile update request
  Future<void> revokeProfileUpdateRequest(String requestId);

  /// Revoke a pending role request
  Future<void> revokeRoleRequest(String requestId);

}
