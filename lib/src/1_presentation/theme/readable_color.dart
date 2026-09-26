import 'package:flutter/material.dart';

extension ReadableColor on Color {
  /// Returns this color adjusted to stay visible as text or an accent on a
  /// surface of [surfaceBrightness]: darker on light surfaces when it is too
  /// light, lighter on dark surfaces when it is too dark.
  Color readableOn(Brightness surfaceBrightness) {
    final luminance = computeLuminance();
    final hsl = HSLColor.fromColor(this);
    return switch (surfaceBrightness) {
      Brightness.light when luminance > 0.45 =>
        hsl
            .withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0))
            .withSaturation((hsl.saturation + 0.2).clamp(0.0, 1.0))
            .toColor(),
      Brightness.dark when luminance < 0.2 =>
        hsl.withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0)).toColor(),
      Brightness.light || Brightness.dark => this,
    };
  }
}
