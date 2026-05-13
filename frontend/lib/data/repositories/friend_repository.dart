import '../models/friend_request_model.dart';
import '../models/friend_model.dart';

/// Abstract repository for friend request operations
abstract class FriendRepository {
  /// Send a friend request by receiver's email
  Future<SendFriendRequestResponse> sendFriendRequest({
    required String email,
    String? note,
  });

  /// Get all sent friend requests (pending)
  Future<List<FriendRequestModel>> getSentRequests();

  /// Get all received friend requests (pending)
  Future<List<FriendRequestModel>> getReceivedRequests();

  /// Accept a friend request
  Future<void> acceptFriendRequest(String requestId);

  /// Reject a friend request
  Future<void> rejectFriendRequest(String requestId);

  /// Cancel a sent friend request
  Future<void> cancelFriendRequest(String requestId);

  /// Remove a friend
  Future<void> removeFriend(String userId);

  /// Get all friends with map mode status
  Future<List<FriendModel>> getFriends();

  /// Batch-update friendMapMode for multiple friends
  Future<void> updateFriendMapModes({
    required List<String> friendIds,
    required bool mapMode,
  });
}
