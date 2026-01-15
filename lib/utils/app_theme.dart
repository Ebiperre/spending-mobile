import 'package:flutter/material.dart';

class AppColors {
  // Minimal palette - Revolut/Wise inspired
  static const Color primary = Color(0xFF0066FF);  // Clean blue accent

  // Neutrals
  static const Color black = Color(0xFF0D0D0D);
  static const Color grey900 = Color(0xFF1A1A1A);
  static const Color grey600 = Color(0xFF6B6B6B);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Status - subtle, not vibrant
  static const Color success = Color(0xFF00A67E);
  static const Color warning = Color(0xFFE5A000);
  static const Color error = Color(0xFFE53935);
  static const Color hot = Color(0xFFD32F2F);

  // Light Theme
  static const Color lightBackground = grey100;
  static const Color lightSurface = white;
  static const Color lightText = black;
  static const Color lightTextSecondary = grey600;

  // Dark Theme
  static const Color darkBackground = black;
  static const Color darkSurface = grey900;
  static const Color darkElevated = Color(0xFF262626);
  static const Color darkText = white;
  static const Color darkTextSecondary = grey400;

  // Keep for backwards compat but not used
  static const Color accent = primary;
  static const Color secondary = primary;
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [black, grey900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static const Color lightPrimary = AppColors.primary;
  static const Color lightBackground = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightText = AppColors.lightText;

  static const Color darkPrimary = AppColors.primary;
  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkText = AppColors.darkText;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightPrimary,
      surface: lightSurface,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.grey600,
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600, letterSpacing: -1),
      displayMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightText),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary),
      labelLarge: TextStyle(color: lightText, fontWeight: FontWeight.w500),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkPrimary,
      surface: darkSurface,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.grey400,
      type: BottomNavigationBarType.fixed,
      backgroundColor: darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600, letterSpacing: -1),
      displayMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkText),
      bodySmall: TextStyle(color: AppColors.darkTextSecondary),
      labelLarge: TextStyle(color: darkText, fontWeight: FontWeight.w500),
    ),
  );
}
