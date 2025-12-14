import 'package:flutter/material.dart';
import '_account_creation_loading_screen.dart';
import '_account_form_screen.dart';
import '_account_creation_success_screen.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  late PageController _pageController;

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
    super.dispose();
  }

  void _handleFormSubmit() {
    // Validate inputs
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dateOfBirthController.text.isEmpty ||
        villageController.text.isEmpty ||
        districtController.text.isEmpty ||
        provinceController.text.isEmpty ||
        nationController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // TODO: Implement actual account creation logic
    print('First Name: ${firstNameController.text}');
    print('Last Name: ${lastNameController.text}');
    print('Date of Birth: ${dateOfBirthController.text}');
    print('Village: ${villageController.text}');
    print('District: ${districtController.text}');
    print('Province: ${provinceController.text}');
    print('Nation: ${nationController.text}');
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');

    // Move to success screen
    _pageController.animateToPage(
      2,
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
          // Success screen
          AccountCreationSuccessScreen(
            onContinue: _handleContinueFromSuccess,
          ),
        ],
      ),
    );
  }
}

