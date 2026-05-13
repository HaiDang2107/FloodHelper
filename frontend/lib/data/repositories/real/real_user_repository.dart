import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../user_repository.dart';

/// Real implementation of UserRepository using backend APIs.
class RealUserRepository implements UserRepository {
  final UserService _userService;

  RealUserRepository({
    required UserService userService,
  })  : _userService = userService;

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _userService.getCurrentUser();
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
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _userService.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }

}
