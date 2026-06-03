import 'package:flutter/material.dart';

class RS7Theme {
  static const Color background = Color(0xff0b0d19); // Deep dark blue-black
  static const Color surface = Color(0xff161a2e);    // Card backgrounds
  static const Color primaryRed = Color(0xffe61c38);  // Vibrant Red Accent
  static const Color ElectricBlue = Color(0xff1473e6); // Secondary Blue Smoke
  static const Color textSilver = Color(0xffcfd4dc);  // Metallic text

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primaryRed,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: ElectricBlue,
      surface: surface,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textSilver, fontFamily: 'Rajdhani'),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
