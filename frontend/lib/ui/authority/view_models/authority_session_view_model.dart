import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authority_session_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthoritySession extends _$AuthoritySession {
  @override
  bool build() {
    return false;
  }

  void signIn() {
    state = true;
  }

  void signOut() {
    state = false;
  }
}
