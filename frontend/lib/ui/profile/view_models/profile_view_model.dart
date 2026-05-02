import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/models/models.dart';
import '../../../data/mappers/domain_mappers.dart';
import '../../../data/models/profile_model.dart'
    show ProfileModel, ProfileRoleRequestModel, UpdateProfileDto;
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/global_session_provider.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_view_model.g.dart';

/// State class for Profile screen using domain model
class ProfileState {
  final UserProfile? profile;
  final List<ProfileRoleRequestModel> roleRequests;
  final bool isLoading;
  final bool isLoadingRoleRequests;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditing;
  
  // Temporary image selections for edit mode (before upload)
  final XFile? tempAvatarImage;
  final XFile? tempFrontCitizenIdImage;
  final XFile? tempBackCitizenIdImage;
  final bool isUploadingImages;

  bool get canSubmitRoleRequest => missingFieldsForRoleRequest.isEmpty;

  List<String> get missingFieldsForRoleRequest {
    final current = profile;
    if (current == null) {
      return ['profile'];
    }

    final missing = <String>[];
    if (current.name.trim().isEmpty) missing.add('fullname');
    if (current.gender == null) missing.add('gender');
    if (current.dateOfBirth == null) missing.add('dob');
    if (current.phoneNumber.trim().isEmpty) missing.add('phoneNumber');
    if ((current.jobPosition ?? '').trim().isEmpty) missing.add('jobPosition');

    final address = current.address;
    if (address?.originProvinceCode == null) missing.add('originProvinceCode');
    if (address?.originWardCode == null) missing.add('originWardCode');
    if (address?.residenceProvinceCode == null) missing.add('residenceProvinceCode');
    if (address?.residenceWardCode == null) missing.add('residenceWardCode');

    final citizen = current.citizenInfo;
    if ((citizen?.citizenId ?? '').trim().isEmpty) missing.add('citizenId');
    if (citizen?.dateOfIssue == null) missing.add('dateOfIssue');
    if (citizen?.dateOfExpire == null) missing.add('dateOfExpire');

    if ((current.avatarUrl ?? '').trim().isEmpty && tempAvatarImage == null) {
      missing.add('avatarUrl');
    }
    if ((citizen?.frontCitizenIdCardImageUrl ?? '').trim().isEmpty &&
        tempFrontCitizenIdImage == null) {
      missing.add('frontCitizenIdCardImageUrl');
    }
    if ((citizen?.backCitizenIdCardImageUrl ?? '').trim().isEmpty &&
        tempBackCitizenIdImage == null) {
      missing.add('backCitizenIdCardImageUrl');
    }

    return missing;
  }

  const ProfileState({
    this.profile,
    this.roleRequests = const [],
    this.isLoading = false,
    this.isLoadingRoleRequests = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
    this.tempAvatarImage,
    this.tempFrontCitizenIdImage,
    this.tempBackCitizenIdImage,
    this.isUploadingImages = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    List<ProfileRoleRequestModel>? roleRequests,
    bool? isLoading,
    bool? isLoadingRoleRequests,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    XFile? tempAvatarImage,
    XFile? tempFrontCitizenIdImage,
    XFile? tempBackCitizenIdImage,
    bool? isUploadingImages,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      roleRequests: roleRequests ?? this.roleRequests,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRoleRequests: isLoadingRoleRequests ?? this.isLoadingRoleRequests,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isEditing: isEditing ?? this.isEditing,
      tempAvatarImage: tempAvatarImage ?? this.tempAvatarImage,
      tempFrontCitizenIdImage: tempFrontCitizenIdImage ?? this.tempFrontCitizenIdImage,
      tempBackCitizenIdImage: tempBackCitizenIdImage ?? this.tempBackCitizenIdImage,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
    );
  }
}

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  late final ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.read(profileRepositoryProvider);
    
    // Auto-load profile on build
    Future.microtask(() async {
      await loadProfile();
      await loadRoleRequests();
    });
    
    return const ProfileState(isLoading: true);
  }

  Future<void> loadRoleRequests() async {
    state = state.copyWith(isLoadingRoleRequests: true, clearError: true);

    try {
      final requests = await _profileRepository.getMyRoleRequests();
      state = state.copyWith(
        roleRequests: requests,
        isLoadingRoleRequests: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingRoleRequests: false,
        errorMessage: 'Failed to load role requests: ${e.toString()}',
      );
    }
  }

  Future<List<ProfileRoleRequestModel>> refreshRoleManagementData() async {
    state = state.copyWith(
      isLoadingRoleRequests: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final requests = await _profileRepository.getMyRoleRequests();
      final profileModel = await _profileRepository.getProfile();
      final updatedProfile = profileModel.toDomain();

      await _syncSessionFromProfile(profileModel);

      state = state.copyWith(
        roleRequests: requests,
        profile: updatedProfile,
        isLoadingRoleRequests: false,
      );

      return requests;
    } catch (e) {
      state = state.copyWith(
        isLoadingRoleRequests: false,
        errorMessage: 'Failed to refresh role data: ${e.toString()}',
      );
      return state.roleRequests;
    }
  }

  Future<bool> submitRoleRequest(UserRole role) async {
    if (!state.canSubmitRoleRequest) {
      state = state.copyWith(
        errorMessage:
            'Please complete required profile fields before sending request: '
            '${state.missingFieldsForRoleRequest.join(', ')}',
      );
      return false;
    }

    final backendType = role == UserRole.benefactor ? 'BENEFACTOR' : 'RESCUER';

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _profileRepository.createRoleRequest(type: backendType);
      await refreshRoleManagementData();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Role request submitted successfully.',
      );
      return true;
    } catch (e) {
      final raw = e.toString().replaceAll('Exception: ', '');
      final message = raw.contains('Profile is incomplete')
          ? 'Please complete your personal information before sending a role request.'
          : raw;
      state = state.copyWith(
        isSaving: false,
        errorMessage: message,
      );
      return false;
    }
  }

  /// Load current user's profile
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final profileModel = await _profileRepository.getProfile();
      await _syncSessionFromProfile(profileModel);
      // Convert data model to domain model
      final profile = profileModel.toDomain();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  /// Cancel editing (revert changes)
  void cancelEditing() {
    state = state.copyWith(isEditing: false);
    // Reload profile to revert any local changes
    loadProfile();
  }

  /// Update profile using domain model
  Future<bool> updateProfile({
    String? fullname,
    String? nickname,
    String? gender,
    String? dob,
    int? originProvinceCode,
    String? originProvinceName,
    int? originWardCode,
    String? originWardName,
    int? residenceProvinceCode,
    String? residenceProvinceName,
    int? residenceWardCode,
    String? residenceWardName,
    String? dateOfIssue,
    String? dateOfExpire,
    String? jobPosition,
    String? citizenId,
    String? avatarUrl,
    String? visibilityMode,
  }) async {
    if (state.profile == null) return false;
    
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    
    try {
      final dto = UpdateProfileDto(
        fullname: fullname,
        nickname: nickname,
        gender: gender,
        dob: dob,
        originProvinceCode: originProvinceCode,
        originProvinceName: originProvinceName,
        originWardCode: originWardCode,
        originWardName: originWardName,
        residenceProvinceCode: residenceProvinceCode,
        residenceProvinceName: residenceProvinceName,
        residenceWardCode: residenceWardCode,
        residenceWardName: residenceWardName,
        dateOfIssue: dateOfIssue,
        dateOfExpire: dateOfExpire,
        jobPosition: jobPosition,
        citizenId: citizenId,
        avatarUrl: avatarUrl,
        visibilityMode: visibilityMode,
      );
      
      final updatedProfileModel = await _profileRepository.updateProfile(
        dto,
        avatar: state.tempAvatarImage,
        frontCitizenId: state.tempFrontCitizenIdImage,
        backCitizenId: state.tempBackCitizenIdImage,
      );
      final normalizedProfileModel = _normalizeUpdatedProfileModel(
        responseModel: updatedProfileModel,
        fallbackOriginProvinceCode: originProvinceCode,
        fallbackOriginProvinceName: originProvinceName,
        fallbackOriginWardCode: originWardCode,
        fallbackOriginWardName: originWardName,
        fallbackResidenceProvinceCode: residenceProvinceCode,
        fallbackResidenceProvinceName: residenceProvinceName,
        fallbackResidenceWardCode: residenceWardCode,
        fallbackResidenceWardName: residenceWardName,
      );

      await _syncSessionFromProfile(normalizedProfileModel);

      // Convert to domain model
      final updatedProfile = normalizedProfileModel.toDomain();
      
      state = state.copyWith(
        profile: updatedProfile,
        isSaving: false,
        isEditing: false,
        tempAvatarImage: null,
        tempFrontCitizenIdImage: null,
        tempBackCitizenIdImage: null,
        successMessage: 'Profile updated successfully!',
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> _syncSessionFromProfile(ProfileModel profileModel) async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.syncSessionUserFromProfile(profileModel);

    final refreshedSession = await authRepository.getCurrentSession();
    if (refreshedSession != null) {
      ref.read(globalSessionManagerProvider.notifier).setSession(refreshedSession);
    }
  }

  ProfileModel _normalizeUpdatedProfileModel({
    required ProfileModel responseModel,
    required int? fallbackOriginProvinceCode,
    required String? fallbackOriginProvinceName,
    required int? fallbackOriginWardCode,
    required String? fallbackOriginWardName,
    required int? fallbackResidenceProvinceCode,
    required String? fallbackResidenceProvinceName,
    required int? fallbackResidenceWardCode,
    required String? fallbackResidenceWardName,
  }) {
    return responseModel.copyWith(
      originProvinceCode: _preferResponseInt(
        responseModel.originProvinceCode,
        fallbackOriginProvinceCode,
      ),
      originProvinceName: _preferResponseString(
        responseModel.originProvinceName,
        fallbackOriginProvinceName,
      ),
      originWardCode: _preferResponseInt(
        responseModel.originWardCode,
        fallbackOriginWardCode,
      ),
      originWardName: _preferResponseString(
        responseModel.originWardName,
        fallbackOriginWardName,
      ),
      residenceProvinceCode: _preferResponseInt(
        responseModel.residenceProvinceCode,
        fallbackResidenceProvinceCode,
      ),
      residenceProvinceName: _preferResponseString(
        responseModel.residenceProvinceName,
        fallbackResidenceProvinceName,
      ),
      residenceWardCode: _preferResponseInt(
        responseModel.residenceWardCode,
        fallbackResidenceWardCode,
      ),
      residenceWardName: _preferResponseString(
        responseModel.residenceWardName,
        fallbackResidenceWardName,
      ),
    );
  }

  int? _preferResponseInt(int? responseValue, int? fallbackValue) {
    return responseValue ?? fallbackValue;
  }

  String? _preferResponseString(String? responseValue, String? fallbackValue) {
    final normalizedResponse = responseValue?.trim();
    if (normalizedResponse != null && normalizedResponse.isNotEmpty) {
      return normalizedResponse;
    }

    final normalizedFallback = fallbackValue?.trim();
    if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }

    return fallbackValue;
  }

  /// Update location
  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      await _profileRepository.updateLocation(
        longitude: longitude,
        latitude: latitude,
      );
      
      // Update local domain state
      if (state.profile != null) {
        state = state.copyWith(
          profile: state.profile!.copyWith(
            location: Location(
              latitude: latitude,
              longitude: longitude,
            ),
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update location: ${e.toString()}',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Sign out user
  /// Clears all auth data and calls backend logout
  Future<void> signOut({bool logoutAll = false}) async {
    try {
      // Call sign out through auth provider
      await ref.read(globalSessionManagerProvider.notifier).signOut(
        logoutAll: logoutAll,
      );
      
      // Clear profile state
      state = const ProfileState();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Set temporary avatar image for preview
  void setTempAvatarImage(XFile? image) {
    state = state.copyWith(tempAvatarImage: image);
  }

  /// Set temporary CCCD front image for preview
  void setTempFrontCitizenIdImage(XFile? image) {
    state = state.copyWith(tempFrontCitizenIdImage: image);
  }

  /// Set temporary CCCD back image for preview
  void setTempBackCitizenIdImage(XFile? image) {
    state = state.copyWith(tempBackCitizenIdImage: image);
  }

  /// Clear all temporary image selections
  void clearTempImages() {
    state = state.copyWith(
      tempAvatarImage: null,
      tempFrontCitizenIdImage: null,
      tempBackCitizenIdImage: null,
    );
  }

}
