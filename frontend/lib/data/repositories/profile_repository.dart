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
    bool? publicMapMode,
  });
  
  /// Get user by ID (public profile)
  Future<ProfileModel?> getUserById(String userId);
}
