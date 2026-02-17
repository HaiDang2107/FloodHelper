import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/data.dart';
import 'code_verification.dart';

part 'forget_password.g.dart';

class ForgetPasswordState {
  final bool isLoading;
  final String? errorMessage;

  const ForgetPasswordState({
    this.isLoading = false,
    this.errorMessage,
  });

  ForgetPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class ForgetPasswordViewModel extends _$ForgetPasswordViewModel
    with AuthCodeVerificationMixin {
  @override
  ForgetPasswordState build() {
    return const ForgetPasswordState();
  }

  final PageController pageController = PageController(initialPage: 0);
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Store username for verification
  String _currentUsername = '';
  
  // Store reset token after code verification
  String? _resetToken;

  @override
  AuthRepository getAuthRepository() {
    return ref.read(authRepositoryProvider);
  }

  @override
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Navigate to next page
  void _goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Navigate to previous page
  void goBack(BuildContext context) {
    if (pageController.page == 0) {
      Navigator.of(context).pop();
    } else {
      pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handle username submission - send verification code
  Future<void> handleUsernameSubmit(BuildContext context) async {
    clearError();

    final username = usernameController.text.trim();
    if (username.isEmpty) {
      setError('Please enter your username');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your username')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.forgotPassword(username: username);

      // Store username for later use
      _currentUsername = username;

      // Navigate to code verification page
      _goToPage(1);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? 'Failed to send verification code')),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Handle code verification
  Future<void> handleCodeSubmitAction(BuildContext context) async {
    await handleCodeSubmit(
      context: context,
      code: codeController.text,
      username: _currentUsername,
      verificationType: VerificationType.forgotPassword,
      onSuccess: (resetToken) {
        // Store reset token for password reset
        _resetToken = resetToken;
        _goToPage(2);
      },
    );
  }

  /// Handle password reset
  Future<void> handlePasswordReset(BuildContext context) async {
    clearError();

    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty) {
      setError('Please enter your new password');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your new password')),
        );
      }
      return;
    }

    if (newPassword.length < 6) {
      setError('Password must be at least 6 characters');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      setError('Passwords do not match');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
      return;
    }

    if (_resetToken == null) {
      setError('Session expired. Please start over.');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please start over.')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.resetPassword(
        newPassword: newPassword,
        resetToken: _resetToken!,
      );

      // Navigate to success page
      _goToPage(3);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? 'Failed to reset password')),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Handle resend verification code
  Future<void> handleResendCodeAction(BuildContext context) async {
    await handleResendCode(
      context: context,
      username: _currentUsername,
      verificationType: VerificationType.forgotPassword,
    );
  }
}
