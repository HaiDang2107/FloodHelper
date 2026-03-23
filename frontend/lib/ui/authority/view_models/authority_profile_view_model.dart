import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/authority/authority_profile.dart';
import '../../../data/providers/authority_providers.dart';

part 'authority_profile_view_model.g.dart';

class AuthorityProfileState {
  const AuthorityProfileState({
    this.profile,
    this.isLoading = false,
  });

  final AuthorityProfile? profile;
  final bool isLoading;

  AuthorityProfileState copyWith({
    AuthorityProfile? profile,
    bool? isLoading,
  }) {
    return AuthorityProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AuthorityProfileViewModel extends _$AuthorityProfileViewModel {
  @override
  AuthorityProfileState build() {
    return const AuthorityProfileState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repository = ref.read(authorityRepositoryProvider);
    final profile = await repository.fetchProfile();
    state = state.copyWith(profile: profile, isLoading: false);
  }
}
