import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Modern color palette with enhanced vibrancy
  static const Color primary = Color(0xFF4D50FF);      // Deep purple
  static const Color secondary = Color(0xFF00B8D4);    // Cyan
  static const Color tertiary = Color(0xFFFF6D00);     // Deep orange

  // Light theme colors
  static const Color lightSurface = Color(0xFFFFFBFE);
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightError = Color(0xFFE53935);

  // Dark theme colors
  static const Color darkSurface = Color(0xFF1F1F1F);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkError = Color(0xFFEF5350);

  // Text colors
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E6E6);

  // Accent colors for various UI elements
  static const Color accent1 = Color(0xFFFFD700);      // Gold
  static const Color accent2 = Color(0xFF00E676);      // Bright green
  static const Color accent3 = Color(0xFFFF4081);      // Pink
  static const Color accent4 = Color(0xFF651FFF);      // Electric violet

  // Enhanced Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF9E7DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00B8D4), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tertiaryGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFF9E40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF1C1B1F).withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: const Color(0xFF1C1B1F).withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: lightSurface,
        background: lightBackground,
        error: lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: lightOnSurface,
        onBackground: lightOnSurface,
        onError: Colors.white,
        surfaceTint: Colors.transparent,
        surfaceVariant: const Color(0xFFE8EAF6),
        onSurfaceVariant: const Color(0xFF49454F),
        outline: const Color(0xFFCAC4D0),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: darkSurface,
        background: darkBackground,
        error: darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: darkOnSurface,
        onBackground: darkOnSurface,
        onError: Colors.white,
        surfaceTint: Colors.transparent,
        surfaceVariant: const Color(0xFF2F2F2F),
        onSurfaceVariant: const Color(0xFFCAC4D0),
        outline: const Color(0xFF49454F),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}