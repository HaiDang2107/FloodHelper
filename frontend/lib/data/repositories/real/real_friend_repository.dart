import '../../models/friend_request_model.dart';
import '../../services/friend_service.dart';
import '../friend_repository.dart';

/// Real implementation of FriendRepository using FriendService
class RealFriendRepository implements FriendRepository {
  final FriendService _friendService;

  RealFriendRepository({FriendService? friendService})
      : _friendService = friendService ?? FriendService();

  @override
  Future<SendFriendRequestResponse> sendFriendRequest({
    required String receiverId,
    String? note,
  }) async {
    return await _friendService.sendFriendRequest(
      receiverId: receiverId,
      note: note,
    );
  }

  @override
  Future<List<FriendRequestModel>> getSentRequests() async {
    return await _friendService.getSentRequests();
  }

  @override
  Future<List<FriendRequestModel>> getReceivedRequests() async {
    return await _friendService.getReceivedRequests();
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    return await _friendService.acceptFriendRequest(requestId);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    return await _friendService.rejectFriendRequest(requestId);
  }

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    return await _friendService.cancelFriendRequest(requestId);
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    return await _friendService.updateFcmToken(fcmToken);
  }
}
