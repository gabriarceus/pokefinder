import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/game_version_color.dart';

void main() {
  group('gameVersionColor', () {
    test('is case insensitive', () {
      expect(gameVersionColor('RED'), Colors.red);
      expect(gameVersionColor('Blue'), Colors.blue);
      expect(gameVersionColor('EmErALd'), Colors.green.shade800);
    });

    test('falls back to grey for unknown versions', () {
      expect(gameVersionColor('colosseum'), Colors.grey);
      expect(gameVersionColor('unknown_version'), Colors.grey);
      expect(gameVersionColor(''), Colors.grey);
    });
  });
}
