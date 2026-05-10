import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/profile_model.dart';
import '../../../data/providers/repository_providers.dart';

part 'admin_user_management_view_model.g.dart';

class AdminUserManagementState {
  const AdminUserManagementState({
    this.email = '',
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  final String email;
  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;

  AdminUserManagementState copyWith({
    String? email,
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminUserManagementState(
      email: email ?? this.email,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class AdminUserManagementViewModel extends _$AdminUserManagementViewModel {
  @override
  AdminUserManagementState build() {
    return const AdminUserManagementState();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
