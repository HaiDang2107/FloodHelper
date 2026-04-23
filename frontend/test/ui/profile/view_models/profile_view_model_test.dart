import 'package:antiflood/data/models/profile_model.dart';
import 'package:antiflood/data/providers/repository_providers.dart';
import 'package:antiflood/data/repositories/auth_repository.dart';
import 'package:antiflood/data/repositories/profile_repository.dart';
import 'package:antiflood/data/services/api_client.dart';
import 'package:antiflood/data/services/auth_service.dart';
import 'package:antiflood/domain/models/auth_session.dart';
import 'package:antiflood/ui/profile/view_models/profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'updateProfile falls back to submitted location values when patch response lacks them',
    () async {
      final fakeProfileRepository = _FakeProfileRepository();
      final fakeAuthRepository = _FakeAuthRepository();

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(profileViewModelProvider.notifier);
      await notifier.loadProfile();
      notifier.toggleEditMode();

      final success = await notifier.updateProfile(
        fullname: 'Updated Name',
        originProvinceCode: 1,
        originProvinceName: 'Ha Noi',
        originWardCode: 101,
        originWardName: 'Dong Da',
        residenceProvinceCode: 79,
        residenceProvinceName: 'Ho Chi Minh',
        residenceWardCode: 26734,
        residenceWardName: 'Ben Nghe',
      );

      expect(success, isTrue);

      final state = container.read(profileViewModelProvider);
      expect(state.profile, isNotNull);
      expect(state.profile!.address?.originProvinceCode, 1);
      expect(state.profile!.address?.originProvinceName, 'Ha Noi');
      expect(state.profile!.address?.originWardCode, 101);
      expect(state.profile!.address?.originWardName, 'Dong Da');
      expect(state.profile!.address?.residenceProvinceCode, 79);
      expect(state.profile!.address?.residenceProvinceName, 'Ho Chi Minh');
      expect(state.profile!.address?.residenceWardCode, 26734);
      expect(state.profile!.address?.residenceWardName, 'Ben Nghe');
      expect(state.isEditing, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.successMessage, 'Profile updated successfully!');

      expect(fakeAuthRepository.syncedProfile, isNotNull);
      expect(fakeAuthRepository.syncedProfile!.originProvinceName, 'Ha Noi');
      expect(fakeAuthRepository.syncedProfile!.originWardName, 'Dong Da');
      expect(
        fakeAuthRepository.syncedProfile!.residenceProvinceName,
        'Ho Chi Minh',
      );
      expect(fakeAuthRepository.syncedProfile!.residenceWardName, 'Ben Nghe');
    },
  );
}

class _FakeProfileRepository implements ProfileRepository {
  ProfileModel _profile = const ProfileModel(
    userId: 'user-1',
    fullname: 'Original Name',
    phoneNumber: '0900000000',
    originProvinceCode: 31,
    originProvinceName: 'Hai Phong',
    originWardCode: 12345,
    originWardName: 'Ward Old Origin',
    residenceProvinceCode: 48,
    residenceProvinceName: 'Da Nang',
    residenceWardCode: 54321,
    residenceWardName: 'Ward Old Residence',
  );

  @override
  Future<ProfileModel> getProfile() async {
    return _profile;
  }

  @override
  Future<List<ProfileRoleRequestModel>> getMyRoleRequests() async {
    return const [];
  }

  @override
  Future<ProfileModel?> getUserById(String userId) async {
    return _profile;
  }

  @override
  Future<void> createRoleRequest({required String type}) async {}

  @override
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  }) async {}

  @override
  Future<ProfileModel> updateProfile(UpdateProfileDto dto) async {
    final patchResponseMissingLocationFields = ProfileModel(
      userId: _profile.userId,
      fullname: dto.fullname ?? _profile.fullname,
      nickname: dto.nickname,
      phoneNumber: _profile.phoneNumber,
      originProvinceCode: null,
      originProvinceName: null,
      originWardCode: null,
      originWardName: null,
      residenceProvinceCode: null,
      residenceProvinceName: null,
      residenceWardCode: null,
      residenceWardName: null,
    );

    _profile = patchResponseMissingLocationFields;
    return patchResponseMissingLocationFields;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository()
      : super(authService: AuthService(apiClient: ApiClient()));

  ProfileModel? syncedProfile;

  @override
  Future<void> syncSessionUserFromProfile(ProfileModel profile) async {
    syncedProfile = profile;
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return null;
  }
}
