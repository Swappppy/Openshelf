import 'package:flutter/material.dart';

/// Centralized theme configuration for the application.
/// Generates both light and dark themes based on a user-selected seed color.
class AppTheme {
  static ThemeData light(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        surface: Colors.black, // Ensures deep black backgrounds for higher contrast
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
