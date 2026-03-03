import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/models.dart';
import '../../../data/mappers/domain_mappers.dart';
import '../../../data/models/profile_model.dart' show UpdateProfileDto;
import '../../../data/providers/repository_providers.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_view_model.g.dart';

/// State class for Profile screen using domain model
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditing;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
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
    Future.microtask(() => loadProfile());
    
    return const ProfileState(isLoading: true);
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
    String? displayName,
    String? gender,
    String? dob,
    String? village,
    String? district,
    String? country,
    String? jobPosition,
    String? citizenId,
    String? avatarUrl,
    bool? publicMapMode,
  }) async {
    if (state.profile == null) return false;
    
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    
    try {
      final dto = UpdateProfileDto(
        displayName: displayName,
        gender: gender,
        dob: dob,
        village: village,
        district: district,
        country: country,
        jobPosition: jobPosition,
        citizenId: citizenId,
        avatarUrl: avatarUrl,
        publicMapMode: publicMapMode,
      );
      
      final updatedProfileModel = await _profileRepository.updateProfile(dto);
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
    bool? publicMapMode,
  }) async {
    try {
      await _profileRepository.updateLocation(
        longitude: longitude,
        latitude: latitude,
        publicMapMode: publicMapMode,
      );
      
      // Update local domain state
      if (state.profile != null) {
        state = state.copyWith(
          profile: state.profile!.copyWith(
            location: Location(
              latitude: latitude,
              longitude: longitude,
            ),
            publicMapMode: publicMapMode ?? state.profile!.publicMapMode,
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
}
