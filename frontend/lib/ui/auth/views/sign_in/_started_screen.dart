import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/circle.dart';

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
        Positioned(
          left: 0,
          right: 0,
          top: 150,
          child: Center(
            child: SvgPicture.asset(
              'lib/assets/man_under_rain.svg',
              height: 300,
            ),
          ),
        ),
        PositionedText(
          text: 'FloodHelper',
          left: 31,
          top: 571,
          width: 350,
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
