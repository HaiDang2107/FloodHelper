import 'package:flutter/material.dart';

/// Custom text input field widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final double width;
  final double borderRadius;
  final double verticalPadding;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.width = 223,
    this.borderRadius = 10,
    this.verticalPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: verticalPadding),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF8E8E8E),
            fontSize: 12,
            fontFamily: 'Anonymous Pro',
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
