import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/authority_providers.dart';
import 'authority_session_view_model.dart';

part 'authority_auth_view_model.g.dart';

class AuthorityAuthState {
  const AuthorityAuthState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  AuthorityAuthState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthorityAuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class AuthorityAuthViewModel extends _$AuthorityAuthViewModel {
  @override
  AuthorityAuthState build() {
    return const AuthorityAuthState();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<void> signIn() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter email and password.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final repository = ref.read(authorityRepositoryProvider);
    final ok = await repository.signIn(state.email, state.password);

    if (ok) {
      ref.read(authoritySessionProvider.notifier).signIn();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid authority credentials.',
      );
      return;
    }

    state = state.copyWith(isLoading: false);
  }
}
