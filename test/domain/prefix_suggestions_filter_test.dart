import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/prefix_suggestions_filter.dart';

void main() {
  group('filterPrefixSuggestions', () {
    const candidates = [
      'pikachu',
      'pidgey',
      'pidgeotto',
      'pidgeot',
      'pikachu-rock-star',
      'pikachu-pop-star',
      'charmander',
      'charizard',
    ];

    test('returns empty when query length is below minLength', () {
      expect(filterPrefixSuggestions(candidates, ''), isEmpty);
      expect(filterPrefixSuggestions(candidates, 'p'), isEmpty);
      expect(filterPrefixSuggestions(candidates, '  p  '), isEmpty);
    });

    test('matches prefix case-insensitively with trimmed input', () {
      final result = filterPrefixSuggestions(candidates, '  PI  ');
      expect(result, [
        'pikachu',
        'pidgey',
        'pidgeotto',
        'pidgeot',
        'pikachu-rock-star',
      ]);
    });

    test('respects limit parameter', () {
      final result = filterPrefixSuggestions(candidates, 'pi', limit: 3);
      expect(result.length, 3);
      expect(result, ['pikachu', 'pidgey', 'pidgeotto']);
    });

    test('excludes entries matching query mid-word', () {
      final result = filterPrefixSuggestions(candidates, 'chu');
      expect(result, isEmpty);
    });

    test('respects custom minLength', () {
      expect(filterPrefixSuggestions(candidates, 'p', minLength: 1, limit: 2), [
        'pikachu',
        'pidgey',
      ]);
    });
  });
}
