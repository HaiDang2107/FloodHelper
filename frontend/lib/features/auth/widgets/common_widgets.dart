import 'package:flutter/material.dart';

/// Reusable decorative circle widget
class DecorativeCircle extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final Color color;

  const DecorativeCircle({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: color,
          shape: const OvalBorder(),
        ),
      ),
    );
  }
}

/// Reusable positioned text widget
class PositionedText extends StatelessWidget {
  final String text;
  final double left;
  final double top;
  final double width;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final double? height;

  const PositionedText({
    super.key,
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.fontSize,
    required this.color,
    this.fontWeight = FontWeight.w400,
    this.textAlign = TextAlign.center,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: width,
        height: height,
        child: Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontFamily: 'Anonymous Pro',
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

/// Reusable background container widget
class ScreenContainer extends StatelessWidget {
  final Color backgroundColor;
  final List<Widget> children;
  final double width;
  final double height;

  const ScreenContainer({
    super.key,
    required this.backgroundColor,
    required this.children,
    this.width = 412,
    this.height = 917,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: backgroundColor),
      child: Stack(children: children),
    );
  }
}
