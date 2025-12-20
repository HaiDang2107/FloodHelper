import 'package:flutter/material.dart';
import '../_send_code_screen.dart';
import '_enter_email_screen.dart';
import '../_success_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  late PageController _pageController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void _handleEmailSubmit() {
    // Here you would typically validate the email and send the code via a service
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleCodeSubmit() {
    // Here you would verify the code
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleBack() {
    if (_pageController.page == 0) {
      Navigator.of(context).pop();
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          EnterEmailScreen(
            emailController: emailController,
            onSubmit: _handleEmailSubmit,
            onBack: _handleBack,
          ),
          SendCodeScreen(
            codeController: codeController,
            onSubmit: _handleCodeSubmit,
            onSendAgain: () {
              // Handle send again logic
            },
            onBack: _handleBack,
          ),
          SuccessScreen(
            message: 'Password Changed Successfully!',
            buttonText: 'Continue',
            onContinue: () {
              // Navigate back to sign in (pop until the first route)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
