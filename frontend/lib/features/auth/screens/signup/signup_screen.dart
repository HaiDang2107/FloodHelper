import 'package:flutter/material.dart';
import '_started_screen.dart';
import '_signup_form_screen.dart';

class SignUpScreen extends StatefulWidget {
  final bool showFormInitially; // Cho phép hiển thị màn hình signup form ngay từ lức đầu

  const SignUpScreen({
    super.key,
    this.showFormInitially = false
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late bool _showForm;

  @override
  void initState() {
    super.initState();
    // Lấy giá trị từ Widget cha truyền xuống để khởi tạo state
    _showForm = widget.showFormInitially;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    // Show the form when user taps "Get started"
    setState(() {
      _showForm = true;
    });
  }

  void _handleSignUp() {
    // Navigate to personal information screen
    Navigator.of(context).pushNamed('/account-creation');
  }

  void _handleSignIn() {
    // TODO: Navigate to login screen
    Navigator.of(context).pushNamed('/home');
  }

  void _handleBack() {
    // Navigate back to the intro screen
    setState(() {
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị started hay signup form dựa trên trạng thái _showForm
    return Scaffold(
      body: _showForm
          ? SignUpFormScreen(
              // Controllers và callbacks để xử lý sự kiện
              emailController: emailController,
              passwordController: passwordController,
              onSignUp: _handleSignUp,
              onSignIn: _handleSignIn,
              onBack: _handleBack, // Added back button handler
            )
          : StartedScreen(
              onGetStarted: _handleGetStarted,
            ),
    );
  }
}

