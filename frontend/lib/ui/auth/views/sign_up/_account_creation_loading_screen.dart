import 'package:flutter/material.dart';
import '../../widgets/circle.dart';

/// Account creation loading screen
class AccountCreationLoadingScreen extends StatelessWidget {
  const AccountCreationLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      backgroundColor: const Color(0xFFFFDF71),
      children: [
        // Decorative circle
        DecorativeCircle(
          left: 37,
          top: 290,
          width: 338,
          height: 338,
          color: Colors.transparent,
        ),
        // Inner circle
        Positioned(
          left: 37,
          top: 290,
          child: SizedBox(
            width: 338,
            height: 338,
            child: Stack(
              children: [
                DecorativeCircle(
                  left: 24,
                  top: 24,
                  width: 290,
                  height: 290,
                  color: const Color(0xFF0F62FE),
                ),
              ],
            ),
          ),
        ),
        // Text content
        PositionedText(
          text: 'creating your',
          left: 91,
          top: 406,
          width: 239,
          fontSize: 16,
          color: Colors.white,
        ),
        PositionedText(
          text: 'AntiFlood',
          left: 84,
          top: 429,
          width: 239,
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        PositionedText(
          text: 'account',
          left: 91,
          top: 476,
          width: 239,
          fontSize: 24,
          color: Colors.white,
        ),
      ],
    );
  }
}
