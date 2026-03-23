import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthorityTheme {
  static const Color brandBlue = Color(0xFF1B4EE4);
  static const Color brandDark = Color(0xFF0F1F45);
  static const Color surface = Color(0xFFF4F6FB);
  static const Color textDark = Color(0xFF101828);
  static const Color accent = Color(0xFF00B3A4);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.merriweatherSansTextTheme(base.textTheme)
        .apply(bodyColor: textDark, displayColor: textDark);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: surface,
      colorScheme: base.colorScheme.copyWith(
        primary: brandBlue,
        secondary: accent,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3E7F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3E7F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandBlue, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
