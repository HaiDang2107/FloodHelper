import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';

/// Account creation success screen
class AccountCreationSuccessScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const AccountCreationSuccessScreen({
    super.key,
    required this.onContinue,
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
          text: 'Your account is created successfully',
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
            text: 'Sign up now',
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
