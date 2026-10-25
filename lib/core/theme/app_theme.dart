import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundLight = Color(0xFFF6F7F2);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundDark = Color(0xFF111511);
  static const Color surfaceDark = Color(0xFF1B211B);
  static const Color textPrimaryLight = Color(0xFF1B1F1B);
  static const Color textSecondaryLight = Color(0xFF626962);
  static const Color textPrimaryDark = Color(0xFFF2F5F2);
  static const Color textSecondaryDark = Color(0xFFB7C0B7);
  static const Color dividerLight = Color(0xFFDDE3DD);
  static const Color dividerDark = Color(0xFF303930);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: dark ? primaryLight : primaryColor,
      secondary: accentColor,
      surface: dark ? surfaceDark : surfaceLight,
      error: errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? backgroundDark : backgroundLight,
      fontFamilyFallback: const ['Noto Serif', 'Georgia', 'serif'],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: dark ? surfaceDark : surfaceLight,
        foregroundColor: dark ? textPrimaryDark : textPrimaryLight,
      ),
      cardTheme: CardThemeData(
        color: dark ? surfaceDark : surfaceLight,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dark ? dividerDark : dividerLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? surfaceDark : surfaceLight,
        indicatorColor: scheme.primaryContainer,
        height: 68,
      ),
      dividerTheme: DividerThemeData(color: dark ? dividerDark : dividerLight),
    );
  }
}
