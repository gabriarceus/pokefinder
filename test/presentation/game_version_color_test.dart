import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/game_version_color.dart';

void main() {
  group('gameVersionColor', () {
    test('maps primary mainline versions to their distinctive colors', () {
      expect(gameVersionColor('red'), Colors.red);
      expect(gameVersionColor('firered'), Colors.red);
      expect(gameVersionColor('blue'), Colors.blue);
      expect(gameVersionColor('leafgreen'), Colors.blue);
      expect(gameVersionColor('yellow'), Colors.amber.shade700);
      expect(gameVersionColor('gold'), Colors.orange.shade400);
      expect(gameVersionColor('silver'), Colors.blueGrey);
      expect(gameVersionColor('crystal'), Colors.cyan);
      expect(gameVersionColor('ruby'), Colors.red.shade900);
      expect(gameVersionColor('sapphire'), Colors.blue.shade900);
      expect(gameVersionColor('emerald'), Colors.green.shade800);
      expect(gameVersionColor('diamond'), Colors.lightBlue);
      expect(gameVersionColor('pearl'), Colors.pink.shade300);
      expect(gameVersionColor('platinum'), Colors.purple.shade300);
      expect(gameVersionColor('black'), Colors.black);
      expect(gameVersionColor('white'), Colors.grey.shade400);
      expect(gameVersionColor('x'), Colors.blue.shade800);
      expect(gameVersionColor('y'), Colors.red.shade800);
      expect(gameVersionColor('sun'), Colors.orange);
      expect(gameVersionColor('moon'), Colors.indigo);
      expect(gameVersionColor('sword'), Colors.cyan.shade800);
      expect(gameVersionColor('shield'), Colors.red.shade700);
      expect(gameVersionColor('scarlet'), Colors.redAccent);
      expect(gameVersionColor('violet'), Colors.deepPurple);
    });

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
