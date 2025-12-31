import 'package:flutter/material.dart';
import '../../services/signin_service.dart';
import '../../services/auth_api_service.dart';
import '../../services/auth_storage.dart';
import '_started_screen.dart';
import '_signin_form_screen.dart';

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
  late final SignInService _signInService;
  late bool _showForm;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lấy giá trị từ Widget cha truyền xuống để khởi tạo state
    _showForm = widget.showFormInitially;
    // Initialize service
    _signInService = SignInService(AuthApiService());
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

  Future<void> _handleSignIn() async {
    if (_isLoading) return; // Prevent multiple calls

    setState(() {
      _isLoading = true;
    });

    try {
      // Call service to handle sign in logic
      final response = await _signInService.signIn(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        // Save authentication data
        await AuthStorage.saveAuthData(response);

        // Handle successful sign in
        print('Sign in successful: $response');
        Navigator.of(context).pushNamed('/home');
      }
    } catch (e) {
      // Handle sign in error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    // Navigate back to the intro screen
    setState(() {
      _showForm = false;
    });
  }

  void _handleForgetPassword() {
    Navigator.of(context).pushNamed('/forget-password');
  }

  // Logout method to clear authentication data
  static Future<void> logout() async {
    await AuthStorage.clearAuthData();
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
              onForgetPassword: _handleForgetPassword,
              isLoading: _isLoading, // Pass loading state
            )
          : StartedScreen(
              onGetStarted: _handleGetStarted,
            ),
    );
  }
}

