import '../models/user_model.dart';

/// Abstract repository for user/friend operations
/// Implement this interface for mock or real data source
abstract class UserRepository {
  /// Get current user info
  Future<UserModel?> getCurrentUser();
  
  /// Get all nearby users (strangers + friends)
  Future<List<UserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  
  /// Get user by ID
  Future<UserModel?> getUserById(String userId);
  
  /// Update current user location
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });
  
}
