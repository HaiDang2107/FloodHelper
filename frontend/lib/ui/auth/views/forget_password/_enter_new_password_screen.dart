import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EnterNewPasswordScreen extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const EnterNewPasswordScreen({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<EnterNewPasswordScreen> createState() => _EnterNewPasswordScreenState();
}

class _EnterNewPasswordScreenState extends State<EnterNewPasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDF71), // Yellow background
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instruction Text
            Text(
              'Enter your new password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F62FE), // Blue text
                fontFamily: 'Anonymous Pro',
              ),
            ),
            const SizedBox(height: 16),

            // New Password Input
            CustomTextField(
              controller: widget.passwordController,
              hintText: 'New password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF0F62FE),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Input
            CustomTextField(
              controller: widget.confirmPasswordController,
              hintText: 'Confirm password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF0F62FE),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            CustomButton(
              text: 'Reset Password',
              backgroundColor: const Color(0xFF0F62FE), // Blue button
              textColor: Colors.white,
              onPressed: widget.onSubmit,
            ),
            const SizedBox(height: 32),

            // Back Button
            GestureDetector(
              onTap: widget.onBack,
              child: Text(
                'Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF0F62FE), // Blue text
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
