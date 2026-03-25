import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers/repository_providers.dart';

part 'authority_session_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthoritySession extends _$AuthoritySession {
  @override
  bool build() {
    Future.microtask(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        state = true;
      }
    });

    return false;
  }

  void signIn() {
    state = true; // Khi state thay đổi, các wwidget đang watch sẽ tự rebuild
  }

  void signOut() {
    final authRepository = ref.read(authRepositoryProvider);
    unawaited(authRepository.signOut());
    state = false;
  }
}
