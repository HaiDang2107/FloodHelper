import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/common_widgets.dart';

/// Introduction screen for sign up
class StartedScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const StartedScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      backgroundColor: const Color(0xFFC8D9F8),
      children: [
        PositionedText(
          text: 'AntiFlood',
          left: 86,
          top: 571,
          width: 239,
          fontSize: 48,
          color: const Color(0xFF0F62FE),
          fontWeight: FontWeight.w700,
        ),
        Positioned(
          left: 55,
          top: 673,
          child: CustomButton(
            text: 'Get started',
            backgroundColor: const Color(0xFF0F62FE),
            textColor: Colors.white,
            onPressed: onGetStarted,
          ),
        ),
      ],
    );
  }
}
