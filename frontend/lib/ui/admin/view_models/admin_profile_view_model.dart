import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/profile_model.dart';
import '../../../data/providers/repository_providers.dart';

part 'admin_profile_view_model.g.dart';

class AdminProfileState {
  const AdminProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;

  AdminProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class AdminProfileViewModel extends _$AdminProfileViewModel {
  @override
  AdminProfileState build() {
    return const AdminProfileState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(adminRepositoryProvider);
      final profile = await repository.getAdminProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}
