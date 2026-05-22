import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Premium Modern Dark Color Palette ─────────────────────────────
  static const _primaryColor = Color(0xFFDDB562); // Elegant soft gold
  static const _secondaryColor = Color(0xFF10B981); // Emerald green
  static const _tertiaryColor = Color(0xFFF59E0B); // Amber
  static const _backgroundColor = Color(0xFF0A0F16); // Very deep slate/black
  static const _surfaceColor = Color(0xFF131B26); // Dark card background
  static const _surface2Color = Color(0xFF1C2738); // Raised surface
  static const _errorColor = Color(0xFFEF4444);

  // ── Custom UI Colors ────────────────────────────────────────────────
  static const Color darkBg = _backgroundColor;
  static const Color surface1 = _surfaceColor;
  static const Color surface2 = _surface2Color;
  static const Color cardBorder = Color(0xFF2A3649); // Subtle slate border
  static const Color warmText = Color(0xFFF8FAFC); // Very light gray
  static const Color dimText = Color(0xFF94A3B8); // Slate 400
  static const Color gold = Color(0xFFDDB562);
  static const Color goldLight = Color(0xFFEAD196);
  static const Color amber = Color(0xFFF59E0B);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _surfaceColor,
      error: _errorColor,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      tertiary: _tertiaryColor,
    ),
    scaffoldBackgroundColor: _backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: _surface2Color,
    ),
    dividerColor: Colors.white10,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface2Color,
      hintStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white70,
      tileColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
      bodyMedium: TextStyle(fontSize: 13, color: Colors.white60),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
  );
}
