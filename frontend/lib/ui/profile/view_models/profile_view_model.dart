import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/models.dart';
import '../../../data/mappers/domain_mappers.dart';
import '../../../data/models/profile_model.dart' show ProfileRoleRequestModel, UpdateProfileDto;
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

  const ProfileState({
    this.profile,
    this.roleRequests = const [],
    this.isLoading = false,
    this.isLoadingRoleRequests = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
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

  Future<bool> submitRoleRequest(UserRole role) async {
    final backendType = role == UserRole.benefactor ? 'BENEFACTOR' : 'RESCUER';

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _profileRepository.createRoleRequest(type: backendType);
      await loadRoleRequests();
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
    String? placeOfOrigin,
    String? placeOfResidence,
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
        placeOfOrigin: placeOfOrigin,
        placeOfResidence: placeOfResidence,
        dateOfIssue: dateOfIssue,
        dateOfExpire: dateOfExpire,
        jobPosition: jobPosition,
        citizenId: citizenId,
        avatarUrl: avatarUrl,
        visibilityMode: visibilityMode,
      );
      
      final updatedProfileModel = await _profileRepository.updateProfile(dto);
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.syncSessionUserFromProfile(updatedProfileModel);

      final refreshedSession = await authRepository.getCurrentSession(); // Sau khi đồng bộ session trong local storage ==> đẩy lại lên Global Session
      if (refreshedSession != null) {
        ref.read(globalSessionManagerProvider.notifier).setSession(refreshedSession);
      }

      // Convert to domain model
      final updatedProfile = updatedProfileModel.toDomain();
      
      state = state.copyWith(
        profile: updatedProfile,
        isSaving: false,
        isEditing: false,
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
}
