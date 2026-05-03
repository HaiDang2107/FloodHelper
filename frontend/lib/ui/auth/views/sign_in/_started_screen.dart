import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/circle.dart';

/// Introduction screen for sign up
class StartedScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final bool isLoading;

  const StartedScreen({
    super.key,
    required this.onGetStarted,
    this.isLoading = false,
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
              'assets/images/man_under_rain.svg',
              height: 300,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 571,
          child: Center(
            child: SizedBox(
              width: 350,
              child: Text(
                'FloodHelper',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F62FE),
                  fontFamily: 'Anonymous Pro',
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 673,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 300,
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F62FE),
                      ),
                    ),
                  )
                : CustomButton(
                    text: 'Get started',
                    backgroundColor: const Color(0xFF0F62FE),
                    textColor: Colors.white,
                    onPressed: onGetStarted,
                  ),
          ),
        ),
      ],
    );
  }
}
