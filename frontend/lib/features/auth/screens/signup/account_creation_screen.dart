import 'package:flutter/material.dart';
import '../../services/account_creation_service.dart';
import '_account_creation_loading_screen.dart';
import '_account_form_screen.dart';
import '_send_code_screen.dart';
import '_account_creation_success_screen.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  late PageController _pageController;
  final AccountCreationService _accountCreationService = AccountCreationService();

  // Controllers for form fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController nationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Auto-advance to form screen after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    villageController.dispose();
    districtController.dispose();
    provinceController.dispose();
    nationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.dispose();
  }

  Future<void> _handleFormSubmit() async {
    // Validate inputs
    final validationError = _accountCreationService.validateForm(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      dateOfBirth: dateOfBirthController.text,
      village: villageController.text,
      district: districtController.text,
      province: provinceController.text,
      nation: nationController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    // Submit account details
    await _accountCreationService.submitAccountDetails(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      dateOfBirth: dateOfBirthController.text,
      village: villageController.text,
      district: districtController.text,
      province: provinceController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    // Move to send code screen
    if (mounted) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleCodeSubmit() {
    // Validate code
    final validationError = _accountCreationService.validateCode(codeController.text);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    // Move to success screen
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleSendAgain() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('We sent again')),
    );
  }

  void _handleBackFromCode() {
    // Go back to form screen
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleBackFromForm() {
    // Go back to loading screen
    Navigator.of(context).pushNamed('/');
  }

  void _handleContinueFromSuccess() {
    // Navigate to login screen
    Navigator.of(context).pushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView xếp các màn hình con nằm ngang hàng nhau
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Tắt cuộn tay
        // Liệt kê các màn hình trong PageView
        children: [
          // Loading screen
          const AccountCreationLoadingScreen(),
          // Form screen
          AccountFormScreen(
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            dateOfBirthController: dateOfBirthController,
            villageController: villageController,
            districtController: districtController,
            provinceController: provinceController,
            nationController: nationController,
            emailController: emailController,
            passwordController: passwordController,
            onSubmit: _handleFormSubmit,
            onBack: _handleBackFromForm,
          ),
          // Send Code Screen
          SendCodeScreen(
            codeController: codeController,
            onSubmit: _handleCodeSubmit,
            onSendAgain: _handleSendAgain,
            onBack: _handleBackFromCode,
          ),
          // Success screen
          AccountCreationSuccessScreen(
            onContinue: _handleContinueFromSuccess,
          ),
        ],
      ),
    );
  }
}

