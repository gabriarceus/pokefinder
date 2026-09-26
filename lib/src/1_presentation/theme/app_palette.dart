import 'package:flutter/material.dart';

/// Centralized color palette and themes of the application.
abstract final class AppPalette {
  /// Brand red, the seed of both color schemes.
  static const Color brandRed = Color(0xFFE53935);

  /// Color for a stat value above the high threshold.
  static const Color statHigh = Colors.green;

  /// Color for a stat value above the medium threshold.
  static const Color statMedium = Colors.amber;

  /// Color for a stat value at or below the medium threshold.
  static const Color statLow = Colors.red;

  /// Light theme configuration for the application.
  static ThemeData get lightTheme => _theme(Brightness.light);

  /// Dark theme configuration for the application.
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: brightness,
      // Keeps primary close to the brand red instead of a muted tone.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        // A red bar is too bright on a near-black page: dark mode uses a
        // raised surface instead.
        backgroundColor: isLight
            ? colorScheme.primary
            : colorScheme.surfaceContainerHigh,
        foregroundColor: isLight
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
      ),
    );
  }
}
