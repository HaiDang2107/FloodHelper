import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../../domain/models/user.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/providers/repository_providers.dart';

part 'admin_user_management_view_model.g.dart';

class AdminUserManagementState {
  const AdminUserManagementState({
    this.email = '',
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.showAddAuthorityModal = false,
    this.showUpdateAuthorityModal = false,
    this.showBanConfirmModal = false,
    this.banningUserId,
    this.isBanningUser = false,
  });

  final String email;
  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool showAddAuthorityModal;
  final bool showUpdateAuthorityModal;
  final bool showBanConfirmModal;
  final String? banningUserId;
  final bool isBanningUser;

  AdminUserManagementState copyWith({
    String? email,
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
    bool? showAddAuthorityModal,
    bool? showUpdateAuthorityModal,
    bool? showBanConfirmModal,
    String? banningUserId,
    bool? isBanningUser,
  }) {
    return AdminUserManagementState(
      email: email ?? this.email,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showAddAuthorityModal: showAddAuthorityModal ?? this.showAddAuthorityModal,
      showUpdateAuthorityModal: showUpdateAuthorityModal ?? this.showUpdateAuthorityModal,
      showBanConfirmModal: showBanConfirmModal ?? this.showBanConfirmModal,
      banningUserId: banningUserId ?? this.banningUserId,
      isBanningUser: isBanningUser ?? this.isBanningUser,
    );
  }

  // Helper getters for button visibility based on user role
  bool get shouldShowBanButton {
    if (profile == null) return false;
    final roles = profile!.roles;
    // If the user is an ADMIN, hide all buttons
    if (roles.contains(UserRole.admin.toBackendString())) return false;
    // Show Ban for any non-admin user who is not already banned
    return profile!.account?.state != 'BANNED';
  }

  bool get shouldShowUnbanButton {
    if (profile == null) return false;
    final roles = profile!.roles;
    if (roles.contains(UserRole.admin.toBackendString())) return false;
    return profile!.account?.state == 'BANNED';
  }

  bool get shouldShowUpdateAuthorityButton {
    if (profile == null) return false;
    final roles = profile!.roles;
    if (roles.contains(UserRole.admin.toBackendString())) return false;
    // Show for AUTHORITY users (unless admin)
    return roles.contains(UserRole.authority.toBackendString());
  }

  bool get isBannedAccount {
    if (profile == null) return false;
    return profile!.account?.state == 'BANNED';
  }
}

@riverpod
class AdminUserManagementViewModel extends _$AdminUserManagementViewModel {
  static const String userNotFoundMessage = '__USER_NOT_FOUND__';

  @override
  AdminUserManagementState build() {
    return const AdminUserManagementState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setProfile(ProfileModel profile) {
    state = state.copyWith(profile: profile, errorMessage: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> search() async {
    final email = state.email.trim();
    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter an email address.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, profile: null);

    try {
      final repository = ref.read(adminRepositoryProvider);
      final profile = await repository.searchUserByEmail(email);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 404) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: userNotFoundMessage,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to search user. Please try again.',
      );
    }
  }

  void toggleAddAuthorityModal() {
    state = state.copyWith(showAddAuthorityModal: !state.showAddAuthorityModal);
  }

  void toggleUpdateAuthorityModal() {
    state = state.copyWith(showUpdateAuthorityModal: !state.showUpdateAuthorityModal);
  }

  void toggleBanConfirmModal() {
    state = state.copyWith(showBanConfirmModal: !state.showBanConfirmModal);
  }

  Future<void> banUser(String userId) async {
    if (state.profile == null) {
      state = state.copyWith(errorMessage: 'No user selected.');
      return;
    }

    state = state.copyWith(banningUserId: userId, isBanningUser: true, errorMessage: null);

    try {
      final repository = ref.read(adminRepositoryProvider);
      final updatedProfile = await repository.banAccount(userId);
      state = state.copyWith(
        profile: updatedProfile,
        isBanningUser: false,
        showBanConfirmModal: false,
        banningUserId: null,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isBanningUser: false,
        errorMessage: 'Failed to ban account: ${error.toString()}',
      );
    }
  }

  Future<void> unbanUser(String userId) async {
    if (state.profile == null) {
      state = state.copyWith(errorMessage: 'No user selected.');
      return;
    }

    state = state.copyWith(banningUserId: userId, isBanningUser: true, errorMessage: null);

    try {
      final repository = ref.read(adminRepositoryProvider);
      final updatedProfile = await repository.unbanAccount(userId);
      state = state.copyWith(
        profile: updatedProfile,
        isBanningUser: false,
        showBanConfirmModal: false,
        banningUserId: null,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isBanningUser: false,
        errorMessage: 'Failed to unban account: ${error.toString()}',
      );
    }
  }
}
