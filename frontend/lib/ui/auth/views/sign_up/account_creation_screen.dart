import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/account_creation.dart';
import '../../widgets/account_not_activated_dialog.dart';
import '_account_creation_loading_screen.dart';
import '_account_form_screen.dart';
import '../_send_code_screen.dart';
import '../_success_screen.dart';

class AccountCreationScreen extends ConsumerStatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  ConsumerState<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends ConsumerState<AccountCreationScreen> {
  @override
  void initState() {
    super.initState();
    // Reset state and auto-advance to form screen after 2 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(accountCreationViewModelProvider.notifier);
      viewModel.resetState();
      viewModel.autoAdvanceToForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch state for reactive updates (isLoading, errorMessage)
    ref.watch(accountCreationViewModelProvider);
    final viewModel = ref.read(accountCreationViewModelProvider.notifier);

    // Listen for showActivationDialog state changes
    ref.listen<AccountCreationState>(
      accountCreationViewModelProvider,
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
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Loading screen
          const AccountCreationLoadingScreen(),
          // Form screen
          AccountFormScreen(
            firstNameController: viewModel.firstNameController,
            lastNameController: viewModel.lastNameController,
            phoneNumberController: viewModel.phoneNumberController,
            dateOfBirthController: viewModel.dateOfBirthController,
            villageController: viewModel.villageController,
            districtController: viewModel.districtController,
            countryController: viewModel.countryController,
            usernameController: viewModel.usernameController,
            passwordController: viewModel.passwordController,
            onSubmit: () => viewModel.handleFormSubmit(context),
            onBack: () => viewModel.handleBackFromForm(context),
            onDatePickerTap: () => viewModel.selectDateOfBirth(context),
          ),

          // Send Code Screen
          SendCodeScreen(
            codeController: viewModel.codeController,
            onSubmit: () => viewModel.handleCodeSubmitAction(context),
            onSendAgain: () => viewModel.handleSendAgain(context),
            onBack: viewModel.handleBackFromCode,
          ),
          // Success screen
          SuccessScreen(
            message: 'Your account is created successfully',
            buttonText: 'Sign in now',
            onContinue: () => viewModel.handleContinueFromSuccess(context),
          ),
          // Email verification screen (for existing inactive accounts)
        ],
      ),
    );
  }
}

