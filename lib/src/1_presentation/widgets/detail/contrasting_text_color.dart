import 'package:flutter/material.dart';

Color contrastingTextColor(Color? backgroundColor) {
  if (backgroundColor == null) return Colors.black;
  return backgroundColor.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
