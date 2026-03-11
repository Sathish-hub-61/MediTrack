import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryLight = Color(0xFF00695C); // Deep Teal
  static const Color secondaryLight = Color(0xFF004D40);
  static const Color accentLight = Color(0xFF26A69A);
  static const Color backgroundLight = Color(0xFFF8FAF9); // Soft Off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A1C1B);
  static const Color onSurfaceVariantLight = Color(0xFF404944);
  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color outlineLight = Color(0xFF707974);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: accentLight,
      surface: surfaceLight,
      surfaceContainerLowest: backgroundLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: onSurfaceVariantLight,
      error: errorLight,
      outline: outlineLight,
      surfaceContainerHighest: const Color(0xFFE0E3E1),
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: onSurfaceLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: onSurfaceLight,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE0E3E1), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E3E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E3E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: onSurfaceLight,
          letterSpacing: -1),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: onSurfaceLight,
          letterSpacing: -0.8),
      displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurfaceLight,
          letterSpacing: -0.5),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: onSurfaceLight),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceLight),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceLight),
      bodyLarge: TextStyle(fontSize: 16, color: onSurfaceLight, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: onSurfaceLight, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariantLight),
    ),
  );

  // ─── Dark Theme ───
  static const Color primaryDark = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF80CBC4);
  static const Color accentDark = Color(0xFF26A69A);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE1E3E1);
  static const Color onSurfaceVariantDark = Color(0xFF9EA9A3);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color outlineDark = Color(0xFF3A3F3C);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLight,
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: secondaryDark,
      tertiary: accentDark,
      surface: surfaceDark,
      surfaceContainerLowest: backgroundDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: onSurfaceVariantDark,
      error: errorDark,
      outline: outlineDark,
      surfaceContainerHighest: const Color(0xFF2C2C2C),
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: onSurfaceDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: onSurfaceDark,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryDark,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3F3C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3A3F3C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: onSurfaceDark,
          letterSpacing: -1),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: onSurfaceDark,
          letterSpacing: -0.8),
      displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurfaceDark,
          letterSpacing: -0.5),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: onSurfaceDark),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceDark),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurfaceDark),
      bodyLarge: TextStyle(fontSize: 16, color: onSurfaceDark, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: onSurfaceDark, height: 1.4),
      bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariantDark),
    ),
  );
}
