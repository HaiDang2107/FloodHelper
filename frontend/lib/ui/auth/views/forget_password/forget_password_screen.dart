import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../_send_code_screen.dart';
import '_enter_email_screen.dart';
import '_enter_new_password_screen.dart';
import '../_success_screen.dart';
import '../../view_models/forget_password.dart';

class ForgetPasswordScreen extends ConsumerWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(forgetPasswordViewModelProvider);
    final viewModel = ref.read(forgetPasswordViewModelProvider.notifier);

    return Scaffold(
      body: PageView(
        controller: viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Page 0: Enter email
          EnterEmailScreen(
            emailController: viewModel.usernameController,
            onSubmit: () => viewModel.handleUsernameSubmit(context),
            onBack: () => viewModel.goBack(context),
          ),
          // Page 1: Enter verification code
          SendCodeScreen(
            codeController: viewModel.codeController,
            onSubmit: () => viewModel.handleCodeSubmitAction(context),
            onSendAgain: () => viewModel.handleResendCodeAction(context),
            onBack: () => viewModel.goBack(context),
          ),
          // Page 2: Enter new password
          EnterNewPasswordScreen(
            passwordController: viewModel.newPasswordController,
            confirmPasswordController: viewModel.confirmPasswordController,
            onSubmit: () => viewModel.handlePasswordReset(context),
            onBack: () => viewModel.goBack(context),
          ),
          // Page 3: Success
          SuccessScreen(
            message: 'Password Changed Successfully!',
            buttonText: 'Continue',
            onContinue: () {
              // Navigate back to sign in (pop until the first route)
              // Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
