import 'package:flutter/material.dart';

/// Relative luminance where black and white text have the same WCAG contrast.
const _kEqualContrastLuminance = 0.179;

/// Returns black or white, whichever has more contrast on [backgroundColor].
Color contrastingTextColor(Color? backgroundColor) {
  if (backgroundColor == null) return Colors.black;
  return backgroundColor.computeLuminance() > _kEqualContrastLuminance
      ? Colors.black
      : Colors.white;
}
