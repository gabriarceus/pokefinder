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

    test('supports natural search queries for form terms and grouping', () {
      final catalog = [
        const PokemonIndexEntry(id: 6, name: 'charizard', detailUrl: ''),
        const PokemonIndexEntry(
          id: 10034,
          name: 'charizard-mega-x',
          detailUrl: '',
          parentSpeciesId: 6,
          parentSpeciesName: 'charizard',
          formCategory: PokemonFormCategory.mega,
        ),
        const PokemonIndexEntry(
          id: 10103,
          name: 'vulpix-alola',
          detailUrl: '',
          parentSpeciesId: 37,
          parentSpeciesName: 'vulpix',
          formCategory: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
        ),
      ];

      final megaMatches = filterIndexSuggestions(catalog, 'mega');
      expect(megaMatches, ['charizard-mega-x']);

      final alolaMatches = filterIndexSuggestions(catalog, 'alola');
      expect(alolaMatches, ['vulpix-alola']);

      final charizardMatches = filterIndexSuggestions(catalog, 'charizard');
      expect(charizardMatches, ['charizard', 'charizard-mega-x']);
    });

    test(
      'does not match canonical species on substrings of internal canonical enum name',
      () {
        final catalog = [
          const PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
          const PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
          const PokemonIndexEntry(id: 10, name: 'caterpie', detailUrl: ''),
          const PokemonIndexEntry(id: 95, name: 'onix', detailUrl: ''),
        ];

        // "ca" matches "caterpie", not "bulbasaur" or "onix"
        final caResults = filterIndexSuggestions(catalog, 'ca');
        expect(caResults, ['caterpie']);

        // "on" matches "onix", not "bulbasaur" or "charmander"
        final onResults = filterIndexSuggestions(catalog, 'on');
        expect(onResults, ['onix']);

        // "an" matches "charmander" (contains "an"), but not "bulbasaur" or "caterpie"
        final anResults = filterIndexSuggestions(catalog, 'an');
        expect(anResults, ['charmander']);
      },
    );
  });
}
