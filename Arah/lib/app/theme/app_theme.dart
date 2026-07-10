import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color arahPurple = Color(0xFF6C63FF);
  static const Color navyBlue = Color(0xFF0B192C);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color successGreen = Color(0xFF28A745);
  static const Color alertRed = Color(0xFFDC3545);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: arahPurple,
      scaffoldBackgroundColor: pureWhite,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: navyBlue),
        titleTextStyle: TextStyle(
          color: navyBlue,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: navyBlue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: navyBlue, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: arahPurple,
          foregroundColor: pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  // Helper to hide scrollbars globally
  static const ScrollBehavior noScrollbarBehavior = ScrollBehavior();
}
