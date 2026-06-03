import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/stat_bar_color.dart';

void main() {
  group('statBarColor', () {
    test('is green for high values (> 90)', () {
      expect(statBarColor(91), Colors.green);
      expect(statBarColor(255), Colors.green);
    });

    test('is amber for medium values (> 50 and <= 90)', () {
      expect(statBarColor(51), Colors.amber);
      expect(statBarColor(90), Colors.amber);
    });

    test('is red for low values (<= 50)', () {
      expect(statBarColor(50), Colors.red);
      expect(statBarColor(0), Colors.red);
    });
  });
}
