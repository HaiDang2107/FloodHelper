import '../models/user_model.dart';

/// Abstract repository for user/friend operations
/// Implement this interface for mock or real data source
abstract class UserRepository {
  /// Get current user info
  Future<UserModel?> getCurrentUser();
  
  /// Get all friends of current user
  Future<List<UserModel>> getFriends();
  
  /// Get all nearby users (strangers + friends)
  Future<List<UserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  
  /// Get user by ID
  Future<UserModel?> getUserById(String userId);
  
  /// Send friend request
  Future<bool> sendFriendRequest(String userId);
  
  /// Accept friend request
  Future<bool> acceptFriendRequest(String userId);
  
  /// Reject friend request
  Future<bool> rejectFriendRequest(String userId);
  
  /// Remove friend
  Future<bool> removeFriend(String userId);
  
  /// Get pending friend requests
  Future<List<UserModel>> getPendingRequests();
  
  /// Update current user location
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  });
  
  /// Broadcast SOS signal
  Future<bool> broadcastSos({
    required int trappedCounts,
    required int childrenNumbers,
    required int elderlyNumbers,
    required bool hasFood,
    required bool hasWater,
    String? other,
  });
  
  /// Revoke SOS signal
  Future<bool> revokeSos();
}
