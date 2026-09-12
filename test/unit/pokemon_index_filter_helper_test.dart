import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('PokemonIndexFilterHelper', () {
    const bulbasaur = PokemonIndexEntry(
      id: 1,
      name: 'bulbasaur',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
      types: [PokemonType.grass, PokemonType.poison],
    );
    const charmander = PokemonIndexEntry(
      id: 4,
      name: 'charmander',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
      types: [PokemonType.fire],
    );
    const charizard = PokemonIndexEntry(
      id: 6,
      name: 'charizard',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/6/',
      types: [PokemonType.fire, PokemonType.flying],
    );
    const squirtle = PokemonIndexEntry(
      id: 7,
      name: 'squirtle',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
      types: [PokemonType.water],
    );
    const pikachu = PokemonIndexEntry(
      id: 25,
      name: 'pikachu',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
      types: [PokemonType.electric],
    );
    const chikorita = PokemonIndexEntry(
      id: 152,
      name: 'chikorita',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/152/',
      types: [PokemonType.grass],
    );

    final entries = [
      bulbasaur,
      charmander,
      charizard,
      squirtle,
      pikachu,
      chikorita,
    ];

    test('text search filters by prefix and contains on name', () {
      final prefixMatches = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        query: 'char',
      );
      expect(prefixMatches.map((e) => e.name), ['charmander', 'charizard']);

      final containsMatches = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        query: 'k',
      );
      expect(containsMatches.map((e) => e.name), ['pikachu', 'chikorita']);
    });

    test('text search matches by numeric ID and formatted ID', () {
      final idMatches = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        query: '25',
      );
      expect(idMatches.map((e) => e.name), ['pikachu']);

      final formattedMatches = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        query: '#004',
      );
      expect(formattedMatches.map((e) => e.name), ['charmander']);
    });

    test('generation filter isolates specific generation bounds', () {
      final gen1 = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        generation: 1,
      );
      expect(gen1.map((e) => e.name), [
        'bulbasaur',
        'charmander',
        'charizard',
        'squirtle',
        'pikachu',
      ]);

      final gen2 = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        generation: 2,
      );
      expect(gen2.map((e) => e.name), ['chikorita']);
    });

    test(
      'type filtering intersects multiple selected types with typeIdMap',
      () {
        final typeIdMap = {
          PokemonType.fire: {4, 6},
          PokemonType.flying: {6},
          PokemonType.grass: {1, 152},
        };

        final fireAndFlying = PokemonIndexFilterHelper.filterAndSort(
          entries: entries,
          selectedTypes: {PokemonType.fire, PokemonType.flying},
          typeIdMap: typeIdMap,
        );
        expect(fireAndFlying.map((e) => e.name), ['charizard']);

        final fireOnly = PokemonIndexFilterHelper.filterAndSort(
          entries: entries,
          selectedTypes: {PokemonType.fire},
          typeIdMap: typeIdMap,
        );
        expect(fireOnly.map((e) => e.name), ['charmander', 'charizard']);
      },
    );

    test(
      'missing type map entries strictly exclude entries with empty types',
      () {
        final entriesWithoutTypes = [
          const PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
          const PokemonIndexEntry(id: 6, name: 'charizard', detailUrl: ''),
        ];

        // 1. Missing entirely from typeIdMap
        final missingResult = PokemonIndexFilterHelper.filterAndSort(
          entries: entriesWithoutTypes,
          selectedTypes: {PokemonType.fire},
          typeIdMap: const {},
        );
        expect(missingResult, isEmpty);

        // 2. Partially resolved types: fire resolved but flying missing
        final partialMap = {
          PokemonType.fire: {4, 6},
        };
        final partialResult = PokemonIndexFilterHelper.filterAndSort(
          entries: entriesWithoutTypes,
          selectedTypes: {PokemonType.fire, PokemonType.flying},
          typeIdMap: partialMap,
        );
        expect(partialResult, isEmpty);
      },
    );

    test('entries with embedded types match even without typeIdMap', () {
      final fireMatches = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        selectedTypes: {PokemonType.fire},
        typeIdMap: const {},
      );
      expect(fireMatches.map((e) => e.name), ['charmander', 'charizard']);
    });

    test('sorting orders entries correctly', () {
      final idDesc = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        sortOrder: PokedexSortOrder.idDescending,
      );
      expect(idDesc.map((e) => e.id), [152, 25, 7, 6, 4, 1]);

      final nameAsc = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        sortOrder: PokedexSortOrder.nameAscending,
      );
      expect(nameAsc.map((e) => e.name), [
        'bulbasaur',
        'charizard',
        'charmander',
        'chikorita',
        'pikachu',
        'squirtle',
      ]);

      final nameDesc = PokemonIndexFilterHelper.filterAndSort(
        entries: entries,
        sortOrder: PokedexSortOrder.nameDescending,
      );
      expect(nameDesc.map((e) => e.name), [
        'squirtle',
        'pikachu',
        'chikorita',
        'charmander',
        'charizard',
        'bulbasaur',
      ]);
    });
  });
}
