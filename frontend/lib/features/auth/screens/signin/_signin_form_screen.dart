import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: SvgPicture.asset('lib/assets/sun.svg'),
          ),
          // Align(
          //   alignment: Alignment.topCenter, // Căn giữa sát trên cùng
          //   child: Padding(
          //     padding: const EdgeInsets.only(top: 200), // Đẩy xuống một khoảng
          //     child: SvgPicture.asset('lib/assets/man_walk.svg', height: 220),
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'lib/assets/wave.svg',
              fit: BoxFit.fitWidth,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 150), // Push content down

                SvgPicture.asset('lib/assets/man_walk.svg', height: 220),

                const SizedBox(height: 20),
                // Title
                Text(
                  'FloodHelper',
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
                  verticalPadding: 8,
                ),
                const SizedBox(height: 12),

                // Password Field and Sign In Button
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        verticalPadding: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Sign in',
                      backgroundColor: const Color(0xFFFFDF71),
                      textColor: const Color(0xFF0F62FE),
                      onPressed: onSignIn,
                      width: 120,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

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
            ),
          ),
        ],
      ),
    );
  }
}
