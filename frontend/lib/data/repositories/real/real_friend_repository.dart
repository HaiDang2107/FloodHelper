import '../../models/friend_request_model.dart';
import '../../models/friend_model.dart';
import '../../services/friend_service.dart';
import '../friend_repository.dart';

/// Real implementation of FriendRepository using FriendService
class RealFriendRepository implements FriendRepository {
  final FriendService _friendService;

  RealFriendRepository({required FriendService friendService})
      : _friendService = friendService;

  @override
  Future<SendFriendRequestResponse> sendFriendRequest({
    required String email,
    String? note,
  }) async {
    return await _friendService.sendFriendRequest(
      email: email,
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
  Future<void> removeFriend(String userId) async {
    // TODO: Implement when unfriend endpoint is available
    throw UnimplementedError('Unfriend endpoint not implemented yet');
  }

  // @override
  // Future<void> updateFcmToken(String fcmToken) async {
  //   return await _friendService.updateFcmToken(fcmToken);
  // }

  @override
  Future<List<FriendModel>> getFriends() async {
    return await _friendService.getFriends();
  }

  @override
  Future<void> updateFriendMapModes({
    required List<String> friendIds,
    required bool mapMode,
  }) async {
    return await _friendService.updateFriendMapModes(
      friendIds: friendIds,
      mapMode: mapMode,
    );
  }
}
