import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('filterIndexSuggestions', () {
    final entries = [
      const PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
      const PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
      const PokemonIndexEntry(id: 5, name: 'charmeleon', detailUrl: ''),
      const PokemonIndexEntry(id: 6, name: 'charizard', detailUrl: ''),
      const PokemonIndexEntry(id: 7, name: 'squirtle', detailUrl: ''),
      const PokemonIndexEntry(id: 25, name: 'pikachu', detailUrl: ''),
      const PokemonIndexEntry(id: 26, name: 'raichu', detailUrl: ''),
    ];

    test('returns empty list when query length is below minLength', () {
      expect(filterIndexSuggestions(entries, ''), isEmpty);
      expect(filterIndexSuggestions(entries, 'c'), isEmpty);
      expect(filterIndexSuggestions(entries, '  c  '), isEmpty);
    });

    test('matches Pokémon by name substring case-insensitively', () {
      final results = filterIndexSuggestions(entries, 'CHAR');
      expect(results, ['charmander', 'charmeleon', 'charizard']);
    });

    test('matches Pokémon by numeric ID and formatted ID prefix', () {
      expect(filterIndexSuggestions(entries, '25'), ['pikachu']);
      expect(filterIndexSuggestions(entries, '#004'), ['charmander']);
    });

    test('caps returned suggestions at limit', () {
      final manyEntries = List.generate(
        10,
        (i) => PokemonIndexEntry(id: i + 100, name: 'test-$i', detailUrl: ''),
      );
      final results = filterIndexSuggestions(manyEntries, 'test', limit: 3);
      expect(results.length, 3);
    });

    test('returns empty list when no matches are found', () {
      expect(filterIndexSuggestions(entries, 'unknown'), isEmpty);
    });
  });
}
