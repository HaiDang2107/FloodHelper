import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EnterEmailScreen extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const EnterEmailScreen({
    super.key,
    required this.emailController,
    required this.onSubmit,
    required this.onBack,
  });

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
              'Enter your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F62FE), // Blue text
                fontFamily: 'Anonymous Pro',
              ),
            ),
            const SizedBox(height: 16),

            // Email Input
            CustomTextField(
              controller: emailController,
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Submit Button
            CustomButton(
              text: 'Submit',
              backgroundColor: const Color(0xFF0F62FE), // Blue button
              textColor: Colors.white,
              onPressed: onSubmit,
            ),
            const SizedBox(height: 32),

            // Back Button
            GestureDetector(
              onTap: onBack,
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
