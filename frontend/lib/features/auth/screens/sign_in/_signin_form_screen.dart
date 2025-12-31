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
  final VoidCallback onBack;
  final VoidCallback onForgetPassword; // Added onForgetPassword callback
  final bool isLoading;

  const SignUpFormScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSignUp,
    required this.onSignIn,
    required this.onBack,
    required this.onForgetPassword, // Added onForgetPassword parameter
    this.isLoading = false,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

            child: Transform(
              transform: Matrix4.diagonal3Values(1.0, 0.5, 1.0),
              alignment: Alignment.bottomRight,
              child: SvgPicture.asset(
                'lib/assets/wave.svg',
                fit: BoxFit.fitWidth,
              ),
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
                    const SizedBox(height: 80), // Push content down

                    SvgPicture.asset('lib/assets/man_walk.svg', height: 200),

                    const SizedBox(height: 10),
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
                    const SizedBox(height: 15),
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
                          text: isLoading ? 'Signing in...' : 'Sign in',
                          backgroundColor: isLoading ? Colors.grey : const Color(0xFFFFDF71),
                          textColor: const Color(0xFF0F62FE),
                          onPressed: isLoading ? () {} : onSignIn,
                          width: 120,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F62FE)),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sign in with Google Button
                    CustomButton(
                      text: 'Sign in with Google',
                      backgroundColor: const Color.fromARGB(255, 127, 194, 248),
                      textColor: Colors.black87,
                      onPressed: () {}, // Placeholder for Google Sign In
                      icon: SvgPicture.asset(
                        'lib/assets/google-icon.svg',
                        height: 24,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Create Account Button
                    CustomButton(
                      text: 'Create Account',
                      backgroundColor: const Color.fromARGB(255, 127, 194, 248),
                      textColor: Colors.black87,
                      onPressed: onSignUp,
                    ),
                    const SizedBox(height: 12),

                    // Forget Password and Back text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: onBack,
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Anonymous Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onForgetPassword,
                          child: Text(
                            'Forget password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Anonymous Pro',
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
