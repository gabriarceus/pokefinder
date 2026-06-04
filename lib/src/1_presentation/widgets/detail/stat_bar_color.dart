import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';

/// Base-stat value above which a stat bar is considered "high".
const _highStatThreshold = 90;

/// Base-stat value above which a stat bar is considered "medium".
const _mediumStatThreshold = 50;

/// Maps a base-stat [value] to its progress-bar color: green when high,
/// amber when medium, red otherwise.
Color statBarColor(int value) {
  if (value > _highStatThreshold) return AppPalette.statHigh;
  if (value > _mediumStatThreshold) return AppPalette.statMedium;
  return AppPalette.statLow;
}
