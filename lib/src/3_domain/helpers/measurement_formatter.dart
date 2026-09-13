import 'package:intl/intl.dart';
import 'package:pokefinder/src/3_domain/entities/unit_system.dart';

/// Formats physical measurements and data sizes according to locale and unit system.
abstract final class MeasurementFormatter {
  static const double _lbsPerKg = 2.20462262185;
  static const double _inchesPerMeter = 39.3700787;

  /// Formats weight given in kilograms according to the specified [system] and [locale].
  static String formatWeight(
    double weightInKg,
    UnitSystem system, {
    String? locale,
  }) {
    final format = NumberFormat('0.0', locale);
    switch (system) {
      case UnitSystem.metric:
        return '${format.format(weightInKg)} kg';
      case UnitSystem.imperial:
        final lbs = weightInKg * _lbsPerKg;
        return '${format.format(lbs)} lbs';
    }
  }

  /// Formats height given in meters according to the specified [system] and [locale].
  static String formatHeight(
    double heightInMeters,
    UnitSystem system, {
    String? locale,
  }) {
    switch (system) {
      case UnitSystem.metric:
        final format = NumberFormat('0.0', locale);
        return '${format.format(heightInMeters)} m';
      case UnitSystem.imperial:
        final totalInches = (heightInMeters * _inchesPerMeter).round();
        final feet = totalInches ~/ 12;
        final inches = totalInches % 12;
        final inchFormat = NumberFormat('00', locale);
        return "$feet' ${inchFormat.format(inches)}\"";
    }
  }

  /// Formats a byte count into a human-readable size string.
  static String formatByteSize(int bytes, {String? locale}) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    final format = NumberFormat('0.0', locale);
    if (bytes < 1024 * 1024) {
      return '${format.format(bytes / 1024)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${format.format(bytes / (1024 * 1024))} MB';
    }
    return '${format.format(bytes / (1024 * 1024 * 1024))} GB';
  }

  /// Formats an integer value according to [locale].
  static String formatInteger(int value, {String? locale}) {
    return NumberFormat.decimalPattern(locale).format(value);
  }
}
