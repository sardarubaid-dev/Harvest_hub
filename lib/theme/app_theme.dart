import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0D631B);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF126D27);
  static const Color secondaryContainer = Color(0xFF9CF49C);
  static const Color onSecondaryContainer = Color(0xFF19722B);
  
  // Surface & Background
  static const Color background = Color(0xFFF7FAF3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE0E3DD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F5EE);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E2);
  static const Color surfaceDim = Color(0xFFD8DBD4);
  static const Color inverseSurface = Color(0xFF2D312D);
  
  // Tertiary
  static const Color onTertiaryContainer = Color(0xFFE8F5E9);
  
  // Text Colors
  static const Color onSurface = Color(0xFF191D19); // Primary text
  static const Color onSurfaceVariant = Color(0xFF40493D); // Secondary text
  static const Color outline = Color(0xFF707A6C); // Borders
  
  // Feedback Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0288D1);
  static const Color success = Color(0xFF2E7D32);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.onSurface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.96),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: -0.24),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: 0.14),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: 0.33),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded-md
          ),
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          side: const BorderSide(color: Color(0x332E7D32)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 1, // Level 1 elevation
        shadowColor: Color(0x0F1B1F1B),
      ),
    );
  }
}
