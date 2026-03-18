import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/friend_service.dart';
import '../user_repository.dart';

/// Real implementation of UserRepository using backend APIs.
class RealUserRepository implements UserRepository {
  final UserService _userService;
  final FriendService _friendService;

  RealUserRepository({
    required UserService userService,
    required FriendService friendService,
  })  : _userService = userService,
        _friendService = friendService;

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  @override
  @Deprecated('Use FriendRepository.getFriends() instead for friend location features')
  Future<List<UserModel>> getFriends() async {
    // NOTE: This method converts FriendModel → UserModel but loses friendMapMode info.
    // For friend location sharing, use FriendRepository.getFriends() which returns FriendModel.
    final friends = await _friendService.getFriends();
    // Convert FriendModel → UserModel for backward compatibility
    return friends
        .map((f) => UserModel(
              id: f.userId,
              name: f.name,
              displayName: f.displayName,
              avatarUrl: f.avatarUrl ?? '',
              status: 'offline',
              latitude: 0,
              longitude: 0,
              isFriend: true,
            ))
        .toList();
  }

  @override
  Future<List<UserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    return await _userService.getNearbyUsers(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    // TODO: Implement when endpoint is available
    return null;
  }

  @override
  Future<bool> sendFriendRequest(String userId) async {
    try {
      await _friendService.sendFriendRequest(receiverId: userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> acceptFriendRequest(String userId) async {
    try {
      await _friendService.acceptFriendRequest(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> rejectFriendRequest(String userId) async {
    try {
      await _friendService.rejectFriendRequest(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeFriend(String userId) async {
    // TODO: Implement when endpoint is available
    return false;
  }

  @override
  Future<List<UserModel>> getPendingRequests() async {
    final requests = await _friendService.getReceivedRequests();
    return requests
        .map((r) => UserModel(
              id: r.user.userId,
              name: r.user.name,
              displayName: r.user.displayName,
              avatarUrl: r.user.avatarUrl ?? '',
              status: 'offline',
              latitude: 0,
              longitude: 0,
            ))
        .toList();
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _userService.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<bool> broadcastSos({
    required int trappedCounts,
    required int childrenNumbers,
    required int elderlyNumbers,
    required bool hasFood,
    required bool hasWater,
    String? other,
  }) async {
    // TODO: Implement when SOS endpoint is available
    return false;
  }

  @override
  Future<bool> revokeSos() async {
    // TODO: Implement when SOS endpoint is available
    return false;
  }
}
