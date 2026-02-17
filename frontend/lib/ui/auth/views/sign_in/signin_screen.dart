import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/signin.dart';
import '_started_screen.dart';
import '_signin_form_screen.dart';

class SignUpScreen extends ConsumerWidget {
  final bool showFormInitially;

  const SignUpScreen({
    super.key,
    this.showFormInitially = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInViewModelProvider(showFormInitially: showFormInitially));
    final viewModel = ref.read(signInViewModelProvider(showFormInitially: showFormInitially).notifier);

    return Scaffold(
      body: state.showForm
          ? SignUpFormScreen(
              emailController: viewModel.emailController,
              passwordController: viewModel.passwordController,
              onSignUp: () => viewModel.handleSignUp(context),
              onSignIn: () => viewModel.handleSignIn(context),
              onBack: viewModel.handleBack,
              onForgetPassword: () => viewModel.handleForgetPassword(context),
              isLoading: state.isLoading,
            )
          : StartedScreen(
              onGetStarted: viewModel.handleGetStarted,
            ),
    );
  }
}

