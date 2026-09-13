import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('MeasurementFormatter', () {
    group('formatWeight', () {
      test('formats metric weights correctly', () {
        expect(
          MeasurementFormatter.formatWeight(
            6.9,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('6.9 kg'),
        );
        expect(
          MeasurementFormatter.formatWeight(
            0.0,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('0.0 kg'),
        );
        expect(
          MeasurementFormatter.formatWeight(
            100.0,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('100.0 kg'),
        );
      });

      test('formats imperial weights correctly', () {
        // 6.9 kg * 2.20462262185 = 15.21189... lbs -> 15.2 lbs
        expect(
          MeasurementFormatter.formatWeight(
            6.9,
            UnitSystem.imperial,
            locale: 'en',
          ),
          equals('15.2 lbs'),
        );
        expect(
          MeasurementFormatter.formatWeight(
            0.0,
            UnitSystem.imperial,
            locale: 'en',
          ),
          equals('0.0 lbs'),
        );
      });
    });

    group('formatHeight', () {
      test('formats metric heights correctly', () {
        expect(
          MeasurementFormatter.formatHeight(
            0.7,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('0.7 m'),
        );
        expect(
          MeasurementFormatter.formatHeight(
            0.0,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('0.0 m'),
        );
        expect(
          MeasurementFormatter.formatHeight(
            2.0,
            UnitSystem.metric,
            locale: 'en',
          ),
          equals('2.0 m'),
        );
      });

      test('formats imperial heights correctly with zero-padded inches', () {
        // 0.7 m * 39.3700787 = 27.559 inches -> 28 inches = 2 feet, 4 inches
        expect(
          MeasurementFormatter.formatHeight(
            0.7,
            UnitSystem.imperial,
            locale: 'en',
          ),
          equals("2' 04\""),
        );
        // 1.0 m * 39.3700787 = 39.37 inches -> 39 inches = 3 feet, 3 inches
        expect(
          MeasurementFormatter.formatHeight(
            1.0,
            UnitSystem.imperial,
            locale: 'en',
          ),
          equals("3' 03\""),
        );
        expect(
          MeasurementFormatter.formatHeight(
            0.0,
            UnitSystem.imperial,
            locale: 'en',
          ),
          equals("0' 00\""),
        );
      });
    });

    group('formatByteSize', () {
      test('formats byte sizes across orders of magnitude', () {
        expect(MeasurementFormatter.formatByteSize(-5), equals('0 B'));
        expect(MeasurementFormatter.formatByteSize(512), equals('512 B'));
        expect(
          MeasurementFormatter.formatByteSize(1024, locale: 'en'),
          equals('1.0 KB'),
        );
        expect(
          MeasurementFormatter.formatByteSize(1536, locale: 'en'),
          equals('1.5 KB'),
        );
        expect(
          MeasurementFormatter.formatByteSize(1024 * 1024, locale: 'en'),
          equals('1.0 MB'),
        );
        expect(
          MeasurementFormatter.formatByteSize(
            (2.5 * 1024 * 1024).round(),
            locale: 'en',
          ),
          equals('2.5 MB'),
        );
        expect(
          MeasurementFormatter.formatByteSize(1024 * 1024 * 1024, locale: 'en'),
          equals('1.0 GB'),
        );
      });
    });
  });
}
