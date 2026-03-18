import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import '../profile_repository.dart';

/// Real implementation of ProfileRepository using ProfileService
class RealProfileRepository implements ProfileRepository {
  final ProfileService _profileService;

  RealProfileRepository({required ProfileService profileService}) 
      : _profileService = profileService;

  @override
  Future<ProfileModel> getProfile() async {
    return await _profileService.getProfile();
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileDto dto) async {
    return await _profileService.updateProfile(dto);
  }

  @override
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    return await _profileService.updateLocation(
      longitude: longitude,
      latitude: latitude,
    );
  }

  @override
  Future<ProfileModel?> getUserById(String userId) async {
    return await _profileService.getUserById(userId);
  }
}
