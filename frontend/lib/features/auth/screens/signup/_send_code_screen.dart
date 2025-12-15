import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SendCodeScreen extends StatelessWidget {
  final TextEditingController codeController;
  final VoidCallback onSubmit;
  final VoidCallback onSendAgain;
  final VoidCallback onBack;

  const SendCodeScreen({
    super.key,
    required this.codeController,
    required this.onSubmit,
    required this.onSendAgain,
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
              'We sent a verification code to your email. Please enter the code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF0F62FE), // Blue text
                fontFamily: 'Anonymous Pro',
              ),
            ),
            const SizedBox(height: 16),

            // Code Input and Submit Button
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: codeController,
                    hintText: 'Code',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Submit',
                  backgroundColor: const Color(0xFF0F62FE), // Blue button
                  textColor: Colors.white,
                  onPressed: onSubmit,
                  width: 120,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Send Again Button
            CustomButton(
              text: 'Send again',
              backgroundColor: const Color(0xFF0F62FE), // Blue button
              textColor: Colors.white,
              onPressed: onSendAgain,
            ),
            const SizedBox(height: 32),

            // Back Button
            GestureDetector(
              onTap: onBack,
              child: Text(
                'back',
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
