import '../../models/profile_model.dart';
import '../profile_repository.dart';

/// Mock implementation of ProfileRepository for development/testing
class MockProfileRepository implements ProfileRepository {
  ProfileModel _currentProfile = ProfileModel(
    userId: 'mock-user-123',
    name: 'Nguyễn Văn An',
    displayName: 'AnNguyen',
    dob: '1995-05-15',
    village: 'Phường Cầu Giấy',
    district: 'Quận Cầu Giấy',
    country: 'Việt Nam',
    roles: const ['USER'],
    longitude: 105.8542,
    latitude: 21.0285,
    publicMapMode: true,
    avatarUrl: 'https://i.pravatar.cc/300',
    citizenId: '001095012345',
    phoneNumber: '0912345678',
    jobPosition: 'Software Engineer',
    account: AccountInfo(
      username: 'annguyen@example.com',
      state: 'ACTIVE',
      createdAt: DateTime(2024, 1, 15),
    ),
  );

  @override
  Future<ProfileModel> getProfile() async {
    await _simulateDelay();
    return _currentProfile;
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileDto dto) async {
    await _simulateDelay();
    
    _currentProfile = _currentProfile.copyWith(
      displayName: dto.displayName ?? _currentProfile.displayName,
      dob: dto.dob ?? _currentProfile.dob,
      village: dto.village ?? _currentProfile.village,
      district: dto.district ?? _currentProfile.district,
      country: dto.country ?? _currentProfile.country,
      longitude: dto.curLongitude ?? _currentProfile.longitude,
      latitude: dto.curLatitude ?? _currentProfile.latitude,
      publicMapMode: dto.publicMapMode ?? _currentProfile.publicMapMode,
      avatarUrl: dto.avatarUrl ?? _currentProfile.avatarUrl,
      citizenId: dto.citizenId ?? _currentProfile.citizenId,
      citizenIdCardImg: dto.citizenIdCardImg ?? _currentProfile.citizenIdCardImg,
      jobPosition: dto.jobPosition ?? _currentProfile.jobPosition,
    );
    
    return _currentProfile;
  }

  @override
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
    bool? publicMapMode,
  }) async {
    await _simulateDelay();
    
    _currentProfile = _currentProfile.copyWith(
      longitude: longitude,
      latitude: latitude,
      publicMapMode: publicMapMode ?? _currentProfile.publicMapMode,
    );
  }

  @override
  Future<ProfileModel?> getUserById(String userId) async {
    await _simulateDelay();
    
    // Mock other users
    if (userId == _currentProfile.userId) {
      return _currentProfile;
    }
    
    // Return a mock user for testing
    return ProfileModel(
      userId: userId,
      name: 'Mock User',
      displayName: 'MockUser',
      roles: ['USER'],
      phoneNumber: '0987654321',
      publicMapMode: false,
    );
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
