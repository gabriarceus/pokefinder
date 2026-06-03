import 'package:flutter/material.dart';

/// Base-stat value above which a stat bar is considered "high".
const _highStatThreshold = 90;

/// Base-stat value above which a stat bar is considered "medium".
const _mediumStatThreshold = 50;

/// Maps a base-stat [value] to its progress-bar color: green when high,
/// amber when medium, red otherwise.
Color statBarColor(int value) {
  if (value > _highStatThreshold) return Colors.green;
  if (value > _mediumStatThreshold) return Colors.amber;
  return Colors.red;
}
