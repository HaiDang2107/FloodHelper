import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Sign up form screen
class SignUpFormScreen extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignUp;
  final VoidCallback onSignIn;
  final VoidCallback onBack; // Added onBack callback

  const SignUpFormScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSignUp,
    required this.onSignIn,
    required this.onBack, // Added onBack parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F62FE),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'AntiFlood',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Email Field
            CustomTextField(
              controller: emailController,
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password Field
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Sign In Button
            CustomButton(
              text: 'Sign in',
              backgroundColor: const Color(0xFFFFDF71),
              textColor: const Color(0xFF0F62FE),
              onPressed: onSignIn,
            ),
            const SizedBox(height: 16),

            // Create Account Button
            CustomButton(
              text: 'Create Account',
              backgroundColor: const Color(0xFFFFDF71),
              textColor: const Color(0xFF0F62FE),
              onPressed: onSignUp,
            ),
            const SizedBox(height: 32),

            // Back text
            GestureDetector(
              onTap: onBack, // Updated to use onBack callback
              child: Text(
                'back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Anonymous Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
