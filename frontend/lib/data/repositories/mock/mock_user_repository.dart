import '../../models/user_model.dart';
import '../user_repository.dart';

/// Mock implementation of UserRepository for development/testing
class MockUserRepository implements UserRepository {
  // Simulated current user
  UserModel? _currentUser = const UserModel(
    id: 'current_user',
    name: 'Current User',
    avatarUrl: 'https://i.pravatar.cc/300',
    status: 'online',
    latitude: 21.0285,
    longitude: 105.8542,
    roles: [],
    isFriend: false,
  );

  // Mock data
  final List<UserModel> _mockUsers = [
    const UserModel(
      id: '1',
      name: 'Nguyễn Văn An',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      status: 'online',
      latitude: 21.0285,
      longitude: 105.8542,
      dateOfBirth: null, // DateTime(1990, 5, 15)
      roles: ['Rescuer'],
      isFriend: true,
    ),
    const UserModel(
      id: '2',
      name: 'Trần Thị Bình',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      status: 'online',
      latitude: 21.0295,
      longitude: 105.8552,
      isSosState: true,
      trappedCounts: 5,
      childrenNumbers: 2,
      elderlyNumbers: 1,
      hasFood: false,
      hasWater: true,
      other: 'Need immediate rescue. Water level rising.',
      isFriend: false,
    ),
    const UserModel(
      id: '3',
      name: 'Lê Văn Cường',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      status: 'offline',
      latitude: 21.0275,
      longitude: 105.8532,
      isFriend: true,
    ),
    const UserModel(
      id: '4',
      name: 'Phạm Thị Dung',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
      status: 'online',
      latitude: 21.0305,
      longitude: 105.8562,
      roles: ['Benefactor'],
      isFriend: true,
    ),
    const UserModel(
      id: '5',
      name: 'Hoàng Văn Em',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      status: 'offline',
      latitude: 21.0265,
      longitude: 105.8522,
      isFriend: false,
    ),
    const UserModel(
      id: '6',
      name: 'Võ Thị Phương',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
      status: 'online',
      latitude: 21.0310,
      longitude: 105.8545,
      isSosState: true,
      trappedCounts: 3,
      childrenNumbers: 1,
      elderlyNumbers: 2,
      hasFood: true,
      hasWater: false,
      other: 'Running low on water supply.',
      roles: ['Authority'],
      isFriend: true,
    ),
  ];

  final List<UserModel> _pendingRequests = [];

  @override
  Future<UserModel?> getCurrentUser() async {
    await _simulateDelay();
    return _currentUser;
  }

  @override
  Future<List<UserModel>> getFriends() async {
    await _simulateDelay();
    return _mockUsers.where((u) => u.isFriend).toList();
  }

  @override
  Future<List<UserModel>> getNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    await _simulateDelay();
    // In real implementation, filter by distance
    return _mockUsers;
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    await _simulateDelay();
    try {
      return _mockUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> sendFriendRequest(String userId) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<bool> acceptFriendRequest(String userId) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<bool> rejectFriendRequest(String userId) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<bool> removeFriend(String userId) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<List<UserModel>> getPendingRequests() async {
    await _simulateDelay();
    return _pendingRequests;
  }

  @override
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _simulateDelay();
    _currentUser = _currentUser?.copyWith(
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
    await _simulateDelay();
    _currentUser = _currentUser?.copyWith(
      isSosState: true,
      trappedCounts: trappedCounts,
      childrenNumbers: childrenNumbers,
      elderlyNumbers: elderlyNumbers,
      hasFood: hasFood,
      hasWater: hasWater,
      other: other,
    );
    return true;
  }

  @override
  Future<bool> revokeSos() async {
    await _simulateDelay();
    _currentUser = _currentUser?.copyWith(
      isSosState: false,
      trappedCounts: null,
      childrenNumbers: null,
      elderlyNumbers: null,
      hasFood: null,
      hasWater: null,
      other: null,
    );
    return true;
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
