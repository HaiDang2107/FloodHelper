import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/data.dart';

part 'signin.g.dart';

class SignInState {
  final bool isLoading;
  final bool showForm;
  final String? errorMessage;

  const SignInState({
    this.isLoading = false,
    this.showForm = false,
    this.errorMessage,
  });

  SignInState copyWith({
    bool? isLoading,
    bool? showForm,
    String? errorMessage,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      showForm: showForm ?? this.showForm,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class SignInViewModel extends _$SignInViewModel {
  @override
  SignInState build({bool showFormInitially = false}) {
    return SignInState(showForm: showFormInitially);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Show sign in form
  void handleGetStarted() {
    state = state.copyWith(showForm: true);
  }

  /// Go back to started screen
  void handleBack() {
    state = state.copyWith(showForm: false);
  }

  /// Navigate to sign up screen
  void handleSignUp(BuildContext context) {
    Navigator.of(context).pushNamed('/account-creation');
  }

  /// Navigate to forget password screen
  void handleForgetPassword(BuildContext context) {
    Navigator.of(context).pushNamed('/forget-password');
  }

  /// Handle sign in
  Future<void> handleSignIn(BuildContext context) async {
    if (state.isLoading) return; // Prevent multiple calls

    clearError();
    setLoading(true);

    try {
      // Use AuthSessionNotifier from providers
      await ref.read(authSessionNotifierProvider.notifier).signIn(
        username: emailController.text,
        password: passwordController.text,
      );

      // Show success message and navigate
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công')),
        );
        Navigator.of(context).pushNamed('/home');
      }
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? 'Đăng nhập thất bại')),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Logout - clear authentication data
  Future<void> logout() async {
    await ref.read(authSessionNotifierProvider.notifier).signOut();
  }
}
