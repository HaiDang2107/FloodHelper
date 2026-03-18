import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/data.dart';
import 'code_verification.dart';

part 'account_creation.g.dart';

class AccountCreationState {
  final bool isLoading;
  final String? errorMessage;
  final bool showActivationDialog;

  const AccountCreationState({
    this.isLoading = false,
    this.errorMessage,
    this.showActivationDialog = false,
  });

  AccountCreationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? showActivationDialog,
  }) {
    return AccountCreationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showActivationDialog: showActivationDialog ?? this.showActivationDialog,
    );
  }
}

@riverpod
class AccountCreationViewModel extends _$AccountCreationViewModel
    with AuthCodeVerificationMixin {
  // @override
  // AccountCreationState build() {
  //   return const AccountCreationState();
  // }

  @override
  AccountCreationState build() {
    // Đăng ký hàm dọn dẹp khi Provider bị hủy
    ref.onDispose(() {
      if (kDebugMode) print('Disposing AccountCreationViewModel resources...');
      
      pageController.dispose();
      firstNameController.dispose();
      lastNameController.dispose();
      phoneNumberController.dispose();
      dateOfBirthController.dispose();
      villageController.dispose();
      districtController.dispose();
      countryController.dispose();
      usernameController.dispose();
      passwordController.dispose();
      codeController.dispose();
      emailController.dispose();
    });

    return const AccountCreationState();
  }

  final PageController pageController = PageController(initialPage: 0);

  // Controllers for form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Store username for verification
  String _currentUsername = '';
  DateTime? selectedDate;

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

  /// Show date picker and update the date of birth field
  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      // Format as YYYY-MM-DD for backend
      dateOfBirthController.text = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  /// Navigate to specific page
  void _goToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// Reset activation dialog flag (called by View after handling dialog)
  void clearActivationDialogFlag() {
    state = state.copyWith(showActivationDialog: false);
  }

  /// Called when user confirms activation in dialog
  Future<void> handleActivateAccount(BuildContext context) async {
    clearActivationDialogFlag();
    
    // Store username and resend verification code
    _currentUsername = usernameController.text;
    
    // Call handleResendCode to send OTP again
    await handleResendCode(
      context: context,
      username: _currentUsername,
      verificationType: VerificationType.signup,
    );
    
    // Navigate to send code screen
    _goToPage(2);
  }

  /// Auto advance to form screen (called after loading screen)
  void autoAdvanceToForm() {
    Future.delayed(const Duration(seconds: 2), () {
      _goToPage(1);
    });
  }

  // // / Reset the view model state (called when screen is revisited)
  // void resetState() {
  //   // Reset page controller to first page
  //   if (pageController.hasClients) {
  //     pageController.jumpToPage(0);
  //   }
    
  //   // Clear all text controllers
  //   firstNameController.clear();
  //   lastNameController.clear();
  //   phoneNumberController.clear();
  //   dateOfBirthController.clear();
  //   villageController.clear();
  //   districtController.clear();
  //   countryController.clear();
  //   usernameController.clear();
  //   passwordController.clear();
  //   codeController.clear();
  //   emailController.clear();
    
  //   // Reset state
  //   _currentUsername = '';
  //   selectedDate = null;
  //   clearError();
  // }

  /// Handle form submission
  Future<void> handleFormSubmit(BuildContext context) async {
    clearError();

    // Validate inputs locally first
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setError('Please fill in all required fields');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')),
        );
      }
      return;
    }

    if (passwordController.text.length < 6) {
      setError('Password must be at least 6 characters');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      // Submit account details
      await authRepository.signUp(
        name: '${firstNameController.text} ${lastNameController.text}',
        phoneNumber: phoneNumberController.text,
        username: usernameController.text,
        password: passwordController.text,
        dob: dateOfBirthController.text.isNotEmpty ? dateOfBirthController.text : null,
        village: villageController.text.isNotEmpty ? villageController.text : null,
        district: districtController.text.isNotEmpty ? districtController.text : null,
        country: countryController.text.isNotEmpty ? countryController.text : null,
      );

      // Store username for verification
      _currentUsername = usernameController.text;

      // Move to send code screen
      _goToPage(2);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      setError(errorMessage);
      
      if (context.mounted) {
        // Check if error is "Account is not activated"
        if (errorMessage.contains('Account is not activated')) {
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

  /// Handle code submission
  Future<void> handleCodeSubmitAction(BuildContext context) async {
    await handleCodeSubmit(
      context: context,
      code: codeController.text,
      username: _currentUsername,
      verificationType: VerificationType.signup,
      onSuccess: (_) => _goToPage(3), // Ignore resetToken for signup flow
    );
  }

  /// Handle resend code
  Future<void> handleSendAgain(BuildContext context) async {
    await handleResendCode(
      context: context,
      username: _currentUsername,
      verificationType: VerificationType.signup,
    );
  }

  /// Go back from code screen to form screen
  void handleBackFromCode() {
    _goToPage(1);
  }

  /// Go back from form screen to sign in
  void handleBackFromForm(BuildContext context) {
    // Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    Navigator.of(context).pop();
  }

  /// Handle continue from success screen
  void handleContinueFromSuccess(BuildContext context) {
    // resetState();
    // Navigator.of(context).pushNamed('/');
    // Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); // Xóa ngăn xếp until ...
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pop();
  }

  /// Handle email submit from email screen
  Future<void> handleEmailSubmit(BuildContext context) async {
    clearError();

    if (emailController.text.isEmpty) {
      setError('Please enter your email');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
      }
      return;
    }

    setLoading(true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      // Resend verification code
      await authRepository.resendCode(
        username: emailController.text,
        type: VerificationType.signup,
      );

      // Store username and navigate to code screen
      _currentUsername = emailController.text;
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

  /// Go back from email screen to form
  void handleBackFromEmail() {
    _goToPage(1);
  }
}
