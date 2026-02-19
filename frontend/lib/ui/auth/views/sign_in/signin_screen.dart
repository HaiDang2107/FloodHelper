import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/signin.dart';
import '../../widgets/account_not_activated_dialog.dart';
import '../_send_code_screen.dart';
import '../_success_screen.dart';
import '_started_screen.dart';
import '_signin_form_screen.dart';

class SignInScreen extends ConsumerWidget {
  final bool showFormInitially;

  const SignInScreen({
    super.key,
    this.showFormInitially = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInViewModelProvider(showFormInitially: showFormInitially));
    final viewModel = ref.read(signInViewModelProvider(showFormInitially: showFormInitially).notifier);

    // Listen for showActivationDialog state changes
    ref.listen<SignInState>(
      signInViewModelProvider(showFormInitially: showFormInitially),
      (previous, next) async {
        if (next.showActivationDialog && !(previous?.showActivationDialog ?? false)) {
          // Show dialog when flag becomes true
          final result = await AccountNotActivatedDialog.show(context);
          if (result == true) {
            viewModel.handleActivateAccount(context);
          } else {
            viewModel.clearActivationDialogFlag();
          }
        }
      },
    );

    return Scaffold(
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          // Page 0: Started screen
          StartedScreen(
            onGetStarted: () => viewModel.handleGetStarted(context),
            isLoading: state.isLoading,
          ),
          // Page 1: Sign in form
          SignInFormScreen(
            emailController: viewModel.emailController,
            passwordController: viewModel.passwordController,
            onSignUp: () => viewModel.handleSignUp(context),
            onSignIn: () => viewModel.handleSignIn(context),
            onBack: viewModel.handleBackFromForm,
            onForgetPassword: () => viewModel.handleForgetPassword(context),
            isLoading: state.isLoading,
          ),
          // Page 2: Code verification (for account activation)
          SendCodeScreen(
            codeController: viewModel.codeController,
            onSubmit: () => viewModel.handleCodeSubmitAction(context),
            onSendAgain: () => viewModel.handleResendCodeAction(context),
            onBack: viewModel.handleBackFromCode,
          ),
          // Page 3: Success screen
          SuccessScreen(
            onContinue: () => viewModel.handleContinueFromSuccess(context),
            message: 'Your account has been activated!',
            buttonText: 'Sign In',
          ),
        ],
      ),
    );
  }
}

