import '../models/profile_model.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get current user's profile
  Future<ProfileModel> getProfile();
  
  /// Update current user's profile
  Future<ProfileModel> updateProfile(UpdateProfileDto dto);
  
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
}
