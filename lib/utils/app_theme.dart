import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM FINTECH COLOR SYSTEM
  // Inspired by Revolut, Cash App, and modern banking interfaces
  // ═══════════════════════════════════════════════════════════════════════════

  // Primary Brand - Rich emerald green (trust, money, growth)
  static const Color primary = Color(0xFF00D09C);  // Vibrant mint green
  static const Color primaryDark = Color(0xFF00B386);  // Deep mint
  static const Color primaryLight = Color(0xFF5EEAD4);  // Light mint

  // Accent - Electric coral (energy, action)
  static const Color accent = Color(0xFFFF6B6B);  // Vibrant coral
  static const Color accentLight = Color(0xFFFF8E8E);  // Soft coral

  // ═══════════════════════════════════════════════════════════════════════════
  // NEUTRAL PALETTE - Premium warm grays with subtle warmth
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color black = Color(0xFF0D0D0D);  // True rich black
  static const Color grey900 = Color(0xFF171717);  // Near black
  static const Color grey800 = Color(0xFF262626);  // Dark charcoal
  static const Color grey700 = Color(0xFF404040);  // Charcoal
  static const Color grey600 = Color(0xFF525252);  // Medium dark
  static const Color grey500 = Color(0xFF737373);  // Medium
  static const Color grey400 = Color(0xFFA3A3A3);  // Muted
  static const Color grey300 = Color(0xFFD4D4D4);  // Light
  static const Color grey200 = Color(0xFFE5E5E5);  // Very light
  static const Color grey100 = Color(0xFFF5F5F5);  // Near white
  static const Color white = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS - Refined, professional tones
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF00D09C);  // Matches primary (consistent brand)
  static const Color successMuted = Color(0xFF00B386);
  static const Color successLight = Color(0xFFD1FAE5);  // For backgrounds

  static const Color warning = Color(0xFFFFB020);  // Rich amber
  static const Color warningMuted = Color(0xFFE5A020);
  static const Color warningLight = Color(0xFFFEF3C7);  // For backgrounds

  static const Color error = Color(0xFFFF4757);  // Vibrant red
  static const Color errorMuted = Color(0xFFE5404F);
  static const Color errorLight = Color(0xFFFEE2E2);  // For backgrounds

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMPERATURE SYSTEM - Sophisticated gradient (Cool → Critical)
  // No emojis - uses elegant color progression
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color tempCool = Color(0xFF00D09C);     // Mint green - healthy
  static const Color tempWarm = Color(0xFFFFB020);     // Amber - caution
  static const Color tempHot = Color(0xFFFF8C42);      // Orange - warning
  static const Color tempBoiling = Color(0xFFFF4757);  // Red - alert
  static const Color tempOverheat = Color(0xFFDC2626); // Deep red - critical

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME - Clean, airy, professional
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFFAFAFA);  // Soft white
  static const Color lightSurface = white;
  static const Color lightSurfaceElevated = Color(0xFFF7F7F7);
  static const Color lightText = Color(0xFF0D0D0D);  // Rich black
  static const Color lightTextSecondary = Color(0xFF737373);  // Medium gray
  static const Color lightBorder = Color(0xFFE5E5E5);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME - Deep, luxurious, modern
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color darkBackground = Color(0xFF0D0D0D);  // True black
  static const Color darkSurface = Color(0xFF171717);  // Elevated black
  static const Color darkElevated = Color(0xFF262626);  // Card surface
  static const Color darkText = Color(0xFFFAFAFA);  // Soft white
  static const Color darkTextSecondary = Color(0xFFA3A3A3);  // Muted text
  static const Color darkBorder = Color(0xFF262626);

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY COLORS - Distinct, recognizable palette
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color categoryFood = Color(0xFFFF8C42);     // Warm orange
  static const Color categoryTransport = Color(0xFF3B82F6); // Blue
  static const Color categoryBills = Color(0xFF8B5CF6);     // Purple
  static const Color categoryEntertainment = Color(0xFFEC4899); // Pink
  static const Color categoryShopping = Color(0xFF00D09C);  // Mint
  static const Color categoryHealth = Color(0xFF10B981);    // Emerald
  static const Color categoryEducation = Color(0xFF6366F1); // Indigo
  static const Color categoryOther = Color(0xFF737373);     // Gray

  // ═══════════════════════════════════════════════════════════════════════════
  // PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D09C), Color(0xFF00B386)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF171717), Color(0xFF262626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF171717), Color(0xFF0D0D0D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass morphism effect colors
  static const Color glassLight = Color(0x1AFFFFFF);  // 10% white
  static const Color glassDark = Color(0x1A000000);   // 10% black

  // Keep for backwards compat
  static const Color secondary = primary;
  static const Color hot = tempBoiling;
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
      secondary: AppColors.accent,
      surface: lightSurface,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
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
      secondary: AppColors.accent,
      surface: darkSurface,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      type: BottomNavigationBarType.fixed,
      backgroundColor: darkSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
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
