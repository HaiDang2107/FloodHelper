import 'package:image_picker/image_picker.dart';

import '../../models/profile_model.dart';
import '../profile_repository.dart';

/// Mock implementation of ProfileRepository for development/testing
class MockProfileRepository implements ProfileRepository {
  final List<ProfileRoleRequestModel> _requests = [
    ProfileRoleRequestModel(
      requestId: 'REQ-MOCK-001',
      type: 'BENEFACTOR',
      state: 'PENDING',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      authorityName: 'Authority A',
    ),
  ];

  final List<ProfileUpdateRequestModel> _profileUpdateRequests = [
    ProfileUpdateRequestModel(
      requestId: 'REQ-PROFILE-001',
      state: 'PENDING',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      authorityName: 'Authority A',
    ),
  ];

  ProfileModel _currentProfile = ProfileModel(
    userId: 'mock-user-123',
    fullname: 'Nguyễn Văn An',
    nickname: 'AnNguyen',
    dob: '1995-05-15',
    // placeOfOrigin: 'Phường Cầu Giấy, Quận Cầu Giấy, Việt Nam',
    // placeOfResidence: 'Phường Cầu Giấy, Quận Cầu Giấy, Việt Nam',
    dateOfIssue: '2020-01-01',
    dateOfExpire: '2035-01-01',
    roles: const ['NORMAL_USER'],
    longitude: 105.8542,
    latitude: 21.0285,
    visibilityMode: 'PUBLIC',
    avatarUrl: 'https://i.pravatar.cc/300',
    citizenId: '001095012345',
    phoneNumber: '0912345678',
    occupation: 'Software Engineer',
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
  Future<ProfileModel> updateProfile(
    UpdateProfileDto dto, {
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  }) async {
    await _simulateDelay();

    _currentProfile = _currentProfile.copyWith(
      fullname: dto.fullname ?? _currentProfile.fullname,
      nickname: dto.nickname ?? _currentProfile.nickname,
      dob: dto.dob ?? _currentProfile.dob,
      // placeOfOrigin: dto.placeOfOrigin ?? _currentProfile.placeOfOrigin,
      // placeOfResidence: dto.placeOfResidence ?? _currentProfile.placeOfResidence,
      dateOfIssue: dto.dateOfIssue ?? _currentProfile.dateOfIssue,
      dateOfExpire: dto.dateOfExpire ?? _currentProfile.dateOfExpire,
      longitude: dto.curLongitude ?? _currentProfile.longitude,
      latitude: dto.curLatitude ?? _currentProfile.latitude,
      visibilityMode: dto.visibilityMode ?? _currentProfile.visibilityMode,
      avatarUrl: avatar != null
          ? 'https://i.pravatar.cc/300'
          : (dto.avatarUrl ?? _currentProfile.avatarUrl),
      citizenId: dto.citizenId ?? _currentProfile.citizenId,
      frontCitizenIdCardImageUrl: frontCitizenId != null
          ? 'https://via.placeholder.com/400x300?text=CCCD+Front'
          : _currentProfile.frontCitizenIdCardImageUrl,
      backCitizenIdCardImageUrl: backCitizenId != null
          ? 'https://via.placeholder.com/400x300?text=CCCD+Back'
          : _currentProfile.backCitizenIdCardImageUrl,
      rescuerCertificateUrl: rescuerCertificate != null
          ? 'https://example.com/mock-rescuer-certificate.pdf'
          : _currentProfile.rescuerCertificateUrl,
      occupation: dto.occupation ?? _currentProfile.occupation,
    );

    return _currentProfile;
  }

  @override
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    await _simulateDelay();

    _currentProfile = _currentProfile.copyWith(
      longitude: longitude,
      latitude: latitude,
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
      fullname: 'Mock User',
      nickname: 'MockUser',
      roles: ['NORMAL_USER'],
      phoneNumber: '0987654321',
      visibilityMode: 'JUST_FRIEND',
    );
  }

  @override
  Future<void> createRoleRequest({required String type}) async {
    await _simulateDelay();
    _requests.insert(
      0,
      ProfileRoleRequestModel(
        requestId: 'REQ-MOCK-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        state: 'PENDING',
        createdAt: DateTime.now(),
        authorityName: 'Authority A',
      ),
    );
  }

  @override
  Future<List<ProfileRoleRequestModel>> getMyRoleRequests() async {
    await _simulateDelay();
    return List<ProfileRoleRequestModel>.from(_requests);
  }

  @override
  Future<List<ProfileUpdateRequestModel>> getMyProfileUpdateRequests() async {
    await _simulateDelay();
    return List<ProfileUpdateRequestModel>.from(_profileUpdateRequests);
  }

  @override
  Future<void> revokeProfileUpdateRequest(String requestId) async {
    await _simulateDelay();
    final index = _profileUpdateRequests.indexWhere(
      (request) => request.requestId == requestId,
    );
    if (index == -1) return;
    final existing = _profileUpdateRequests[index];
    _profileUpdateRequests[index] = ProfileUpdateRequestModel(
      requestId: existing.requestId,
      state: 'REVOKED',
      note: existing.note,
      createdAt: existing.createdAt,
      respondedAt: DateTime.now(),
      authorityName: existing.authorityName,
    );
  }

  @override
  Future<void> createProfileUpdateRequest({
    required Map<String, dynamic> body,
    XFile? avatar,
    XFile? frontCitizenId,
    XFile? backCitizenId,
    XFile? rescuerCertificate,
  }) async {
    await _simulateDelay();
    _profileUpdateRequests.insert(
      0,
      ProfileUpdateRequestModel(
        requestId: 'REQ-PROFILE-${DateTime.now().millisecondsSinceEpoch}',
        state: 'PENDING',
        createdAt: DateTime.now(),
        authorityName: null,
      ),
    );
  }

  @override
  Future<void> revokeRoleRequest(String requestId) async {
    await _simulateDelay();
    final index = _requests.indexWhere(
      (request) => request.requestId == requestId,
    );
    if (index == -1) return;
    final existing = _requests[index];
    _requests[index] = ProfileRoleRequestModel(
      requestId: existing.requestId,
      type: existing.type,
      state: 'REVOKED',
      note: existing.note,
      createdAt: existing.createdAt,
      responsedAt: DateTime.now(),
      authorityName: existing.authorityName,
    );
  }

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
