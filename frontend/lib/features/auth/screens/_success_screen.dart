import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/circle.dart';

/// Generic success screen
class SuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final String message;
  final String buttonText;

  const SuccessScreen({
    super.key,
    required this.onContinue,
    required this.message,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      backgroundColor: const Color(0xFFFFDF71),
      children: [
        // Decorative circle
        DecorativeCircle(
          left: 61,
          top: 314,
          width: 290,
          height: 290,
          color: const Color(0xFF0F62FE),
        ),
        // Success message
        PositionedText(
          text: message,
          left: 86,
          top: 398,
          width: 239,
          fontSize: 16,
          color: Colors.white,
        ),
        // Continue button
        Positioned(
          left: 133,
          top: 453,
          child: CustomButton(
            text: buttonText,
            backgroundColor: Colors.white,
            textColor: const Color(0xFF0F62FE),
            onPressed: onContinue,
            width: 140,
          ),
        ),
      ],
    );
  }
}
