import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../routing/routes.dart';
import '../../../data/data.dart';
import 'code_verification.dart';

part 'signin.g.dart';

class SignInState {
  final bool isLoading;
  final String? errorMessage;
  final bool showActivationDialog; // Flag to notify View to show dialog

  const SignInState({
    this.isLoading = false,
    this.errorMessage,
    this.showActivationDialog = false,
  });

  SignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? showActivationDialog,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showActivationDialog: showActivationDialog ?? this.showActivationDialog,
    );
  }
}

@Riverpod(keepAlive: false)
class SignInViewModel extends _$SignInViewModel with AuthCodeVerificationMixin {
  @override
  SignInState build({bool showFormInitially = false}) {
    // Register cleanup when provider is disposed
    ref.onDispose(() {
      pageController.dispose();
      emailController.dispose();
      passwordController.dispose();
      codeController.dispose();
    });

    return const SignInState();
  }

  final PageController pageController = PageController(initialPage: 0);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // Store username for verification
  String _currentUsername = '';

  @override
  AuthRepository getAuthRepository() {
    return ref.read(authRepositoryProvider);
  }

  @override
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  @override
  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  @override
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Navigate to specific page
  void _goToPage(int page, {bool animate = true}) {
    if (animate) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.jumpToPage(page);
    }
  }

  /// Handle "Get Started" button tap - try auto login first
  Future<void> handleGetStarted(BuildContext context) async {
    if (state.isLoading) return;

    setLoading(true);

    try {
      // Try auto login using refresh token from cookie
      final authSession = await ref.read(authRepositoryProvider).tryAutoLogin();

      if (authSession != null) {
        // Auto login successful - update auth state and navigate to home
        ref.read(globalSessionManagerProvider.notifier).setSession(authSession);
        
        // Register FCM token immediately after auto login
        try {
          await ref.read(firebaseMessagingServiceProvider).registerToken();
        } catch (fcmError) {
          // Don't block user if FCM registration fails
          debugPrint('⚠️ FCM registration failed: $fcmError');
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome back!')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else {
        // No valid refresh token - go to sign in form
        _goToPage(1);
      }
    } catch (e) {
      // Auto login failed - go to sign in form
      _goToPage(1);
    } finally {
      setLoading(false);
    }
  }

  /// Navigate from loading screen to form (tap to continue) - legacy method
  void goToFormScreen() {
    _goToPage(1);
  }

  /// Navigate to sign up screen
  void handleSignUp(BuildContext context) {
    Navigator.of(context).pushNamed('/account-creation');
  }

  /// Navigate to forget password screen
  void handleForgetPassword(BuildContext context) {
    Navigator.of(context).pushNamed('/forget-password');
  }

  /// Go back from form screen
  void handleBackFromForm() {
    _goToPage(0);
  }

  /// Go back from code screen
  void handleBackFromCode() {
    _goToPage(1);
  }

  /// Handle sign in
  Future<void> handleSignIn(BuildContext context) async {
    if (state.isLoading) return;

    clearError();
    
    final username = emailController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setError('Please enter email and password');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      await ref.read(globalSessionManagerProvider.notifier).signIn(
        username: username,
        password: password,
      );

      // Register FCM token immediately after successful login
      try {
        await ref.read(firebaseMessagingServiceProvider).registerToken();
      } catch (fcmError) {
        // Don't block user if FCM registration fails
        debugPrint('⚠️ FCM registration failed: $fcmError');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      setError(errorMessage);

      if (context.mounted) {
        // Check if error is "Account is not activated"
        if (errorMessage.contains('Account is not activated')) {
          _currentUsername = username;
          // Notify View to show dialog via state
          state = state.copyWith(showActivationDialog: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } finally {
      setLoading(false);
    }
  }

  /// Reset activation dialog flag (called by View after handling dialog)
  void clearActivationDialogFlag() {
    state = state.copyWith(showActivationDialog: false);
  }

  /// Called when user confirms activation in dialog
  Future<void> handleActivateAccount(BuildContext context) async {
    clearActivationDialogFlag();
    await _resendActivationCode(context);
  }

  /// Resend activation code and navigate to code screen
  Future<void> _resendActivationCode(BuildContext context) async {
    setLoading(true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      await authRepository.resendCode(
        username: _currentUsername,
        type: VerificationType.signup,
      );

      // Navigate to code verification screen
      _goToPage(2);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to your email')),
        );
      }
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? 'Failed to send code')),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  /// Handle code submission for account activation
  Future<void> handleCodeSubmitAction(BuildContext context) async {
    await handleCodeSubmit(
      context: context,
      code: codeController.text,
      username: _currentUsername,
      verificationType: VerificationType.signup,
      onSuccess: (_) => _goToPage(3),
    );
  }

  /// Handle resend code
  Future<void> handleResendCodeAction(BuildContext context) async {
    await handleResendCode(
      context: context,
      username: _currentUsername,
      verificationType: VerificationType.signup,
    );
  }

  /// Handle continue from success screen - go back to sign in form
  void handleContinueFromSuccess(BuildContext context) {
    // Clear code and go back to form to sign in again
    codeController.clear();
    _goToPage(1, animate: false); // Jump directly without animation
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account activated! Please sign in.')),
      );
    }
  }

  /// Logout - clear authentication data
  Future<void> logout() async {
    await ref.read(globalSessionManagerProvider.notifier).signOut();
  }
}
