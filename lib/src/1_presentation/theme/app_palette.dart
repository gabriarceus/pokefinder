import 'package:flutter/material.dart';

/// Centralized color palette for brand chrome that is not derived from the
/// ambient [ThemeData]. Keeps recurring color literals in a single place so
/// they stay consistent and easy to retune.
abstract final class AppPalette {
  /// Primary brand red used for action buttons and drawer chrome.
  static const Color brandRed = Colors.red;

  /// Foreground color drawn on top of [brandRed] surfaces.
  static const Color onBrandRed = Colors.white;

  /// Fill of the decorative pokeball on the home screen.
  static const Color pokeballAccent = Color.fromARGB(255, 223, 112, 104);

  /// Color for a stat value above the high threshold.
  static const Color statHigh = Colors.green;

  /// Color for a stat value above the medium threshold.
  static const Color statMedium = Colors.amber;

  /// Color for a stat value at or below the medium threshold.
  static const Color statLow = Colors.red;
}
