import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/text_normalizer.dart';

void main() {
  group('TextNormalizer', () {
    test('cleans form feeds and newlines from PokeAPI flavor text', () {
      const rawText =
          'A strange seed was\nplanted on its\nback at birth.\fThe plant sprouts\nand grows with\nthis POKéMON.';
      final cleaned = TextNormalizer.cleanPokeApiText(rawText);
      expect(
        cleaned,
        'A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.',
      );
    });

    test('replaces carriage returns and tabs with single space', () {
      const rawText = 'Line one\r\nLine two\twith tab';
      final cleaned = TextNormalizer.cleanPokeApiText(rawText);
      expect(cleaned, 'Line one Line two with tab');
    });

    test('collapses multiple consecutive whitespaces into one', () {
      const rawText = 'Too    many   spaces   here';
      final cleaned = TextNormalizer.cleanPokeApiText(rawText);
      expect(cleaned, 'Too many spaces here');
    });

    test('handles empty and whitespace-only strings gracefully', () {
      expect(TextNormalizer.cleanPokeApiText(''), '');
      expect(TextNormalizer.cleanPokeApiText('   \n\f\t  '), '');
    });
  });
}
