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

    test(
      'default canonicalOnly filter hides alternate forms unless searching',
      () {
        const venusaur = PokemonIndexEntry(
          id: 3,
          name: 'venusaur',
          detailUrl: '',
        );
        const megaVenusaur = PokemonIndexEntry(
          id: 10033,
          name: 'venusaur-mega',
          detailUrl: '',
          parentSpeciesId: 3,
          formCategory: PokemonFormCategory.mega,
        );
        final catalog = [venusaur, megaVenusaur];

        final defaultFiltered = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
        );
        expect(defaultFiltered.map((e) => e.name), ['venusaur']);

        final searchFiltered = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'mega',
        );
        expect(searchFiltered.map((e) => e.name), ['venusaur-mega']);
      },
    );

    test(
      'all forms mode interleaves forms directly beneath parent species',
      () {
        const venusaur = PokemonIndexEntry(
          id: 3,
          name: 'venusaur',
          detailUrl: '',
        );
        const megaVenusaur = PokemonIndexEntry(
          id: 10033,
          name: 'venusaur-mega',
          detailUrl: '',
          parentSpeciesId: 3,
          formCategory: PokemonFormCategory.mega,
        );
        const charmander = PokemonIndexEntry(
          id: 4,
          name: 'charmander',
          detailUrl: '',
        );
        final catalog = [charmander, megaVenusaur, venusaur];

        final interleaved = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          formFilter: PokedexFormFilter.all,
          sortOrder: PokedexSortOrder.idAscending,
        );

        // Verifies: Venusaur -> Mega Venusaur -> Charmander
        expect(interleaved.map((e) => e.name), [
          'venusaur',
          'venusaur-mega',
          'charmander',
        ]);
      },
    );

    test('formCategory filters isolate Megas, Regionals, and G-Max', () {
      const megaVenusaur = PokemonIndexEntry(
        id: 10033,
        name: 'venusaur-mega',
        detailUrl: '',
        parentSpeciesId: 3,
        formCategory: PokemonFormCategory.mega,
      );
      const alolanVulpix = PokemonIndexEntry(
        id: 10103,
        name: 'vulpix-alola',
        detailUrl: '',
        parentSpeciesId: 37,
        formCategory: PokemonFormCategory.regional,
        regionalGroup: PokemonRegionalGroup.alola,
      );
      const gmaxGengar = PokemonIndexEntry(
        id: 10198,
        name: 'gengar-gmax',
        detailUrl: '',
        parentSpeciesId: 94,
        formCategory: PokemonFormCategory.gmax,
      );
      final catalog = [megaVenusaur, alolanVulpix, gmaxGengar];

      final megas = PokemonIndexFilterHelper.filterAndSort(
        entries: catalog,
        formFilter: PokedexFormFilter.mega,
      );
      expect(megas.map((e) => e.name), ['venusaur-mega']);

      final regionals = PokemonIndexFilterHelper.filterAndSort(
        entries: catalog,
        formFilter: PokedexFormFilter.regional,
      );
      expect(regionals.map((e) => e.name), ['vulpix-alola']);

      final gmax = PokemonIndexFilterHelper.filterAndSort(
        entries: catalog,
        formFilter: PokedexFormFilter.gmax,
      );
      expect(gmax.map((e) => e.name), ['gengar-gmax']);
    });

    test('cosmetic forms are suppressed by default and enabled via toggle', () {
      const pikachu = PokemonIndexEntry(id: 25, name: 'pikachu', detailUrl: '');
      const pikachuCap = PokemonIndexEntry(
        id: 10094,
        name: 'pikachu-original-cap',
        detailUrl: '',
        parentSpeciesId: 25,
        formCategory: PokemonFormCategory.cosmetic,
      );
      final catalog = [pikachu, pikachuCap];

      final defaultExcludes = PokemonIndexFilterHelper.filterAndSort(
        entries: catalog,
        formFilter: PokedexFormFilter.all,
      );
      expect(defaultExcludes.map((e) => e.name), ['pikachu']);

      final included = PokemonIndexFilterHelper.filterAndSort(
        entries: catalog,
        formFilter: PokedexFormFilter.all,
        includeCosmeticForms: true,
      );
      expect(included.map((e) => e.name), ['pikachu', 'pikachu-original-cap']);
    });

    test(
      'dual generation filter matches both species generation and debut generation',
      () {
        const megaVenusaur = PokemonIndexEntry(
          id: 10033,
          name: 'venusaur-mega',
          detailUrl: '',
          parentSpeciesId: 3,
          formCategory: PokemonFormCategory.mega,
          speciesGeneration: 1,
          introductionGeneration: 6,
        );
        const alolanRaichu = PokemonIndexEntry(
          id: 10100,
          name: 'raichu-alola',
          detailUrl: '',
          parentSpeciesId: 26,
          formCategory: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
          speciesGeneration: 1,
          introductionGeneration: 7,
        );
        final catalog = [megaVenusaur, alolanRaichu];

        // Gen 1 matches both because parent species are Gen 1
        final gen1 = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          formFilter: PokedexFormFilter.all,
          generation: 1,
        );
        expect(gen1.map((e) => e.name), ['venusaur-mega', 'raichu-alola']);

        // Gen 6 matches Mega Venusaur
        final gen6 = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          formFilter: PokedexFormFilter.all,
          generation: 6,
        );
        expect(gen6.map((e) => e.name), ['venusaur-mega']);

        // Gen 7 matches Alolan Raichu
        final gen7 = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          formFilter: PokedexFormFilter.all,
          generation: 7,
        );
        expect(gen7.map((e) => e.name), ['raichu-alola']);
      },
    );

    test(
      'natural query search matches terms like "mega", "alola", and species name',
      () {
        const charizard = PokemonIndexEntry(
          id: 6,
          name: 'charizard',
          detailUrl: '',
        );
        const megaCharizard = PokemonIndexEntry(
          id: 10034,
          name: 'charizard-mega-x',
          detailUrl: '',
          parentSpeciesId: 6,
          parentSpeciesName: 'charizard',
          formCategory: PokemonFormCategory.mega,
        );
        const alolanVulpix = PokemonIndexEntry(
          id: 10103,
          name: 'vulpix-alola',
          detailUrl: '',
          parentSpeciesId: 37,
          parentSpeciesName: 'vulpix',
          formCategory: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
        );
        final catalog = [charizard, megaCharizard, alolanVulpix];

        final megaMatches = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'mega',
        );
        expect(megaMatches.map((e) => e.name), ['charizard-mega-x']);

        final alolaMatches = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'alola',
        );
        expect(alolaMatches.map((e) => e.name), ['vulpix-alola']);

        final charizardMatches = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'charizard',
        );
        expect(charizardMatches.map((e) => e.name), [
          'charizard',
          'charizard-mega-x',
        ]);
      },
    );

    test(
      'natural query search does not match canonical entries on substrings of "canonical"',
      () {
        const bulbasaur = PokemonIndexEntry(
          id: 1,
          name: 'bulbasaur',
          detailUrl: '',
        );
        const charmander = PokemonIndexEntry(
          id: 4,
          name: 'charmander',
          detailUrl: '',
        );
        const caterpie = PokemonIndexEntry(
          id: 10,
          name: 'caterpie',
          detailUrl: '',
        );
        const onix = PokemonIndexEntry(id: 95, name: 'onix', detailUrl: '');
        final catalog = [bulbasaur, charmander, caterpie, onix];

        final caResults = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'ca',
        );
        expect(caResults.map((e) => e.name), ['caterpie']);

        final onResults = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'on',
        );
        expect(onResults.map((e) => e.name), ['onix']);

        final anResults = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          query: 'an',
        );
        expect(anResults.map((e) => e.name), ['charmander']);
      },
    );

    test(
      'type filter matches alternate form by its own ID rather than parent species ID',
      () {
        const vulpix = PokemonIndexEntry(
          id: 37,
          name: 'vulpix',
          detailUrl: '',
          parentSpeciesId: 37,
        );
        const alolanVulpix = PokemonIndexEntry(
          id: 10103,
          name: 'vulpix-alola',
          detailUrl: '',
          parentSpeciesId: 37,
          formCategory: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
        );
        final catalog = [vulpix, alolanVulpix];
        final typeIdMap = {
          PokemonType.fire: {37},
          PokemonType.ice: {10103},
        };

        final fireResults = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          selectedTypes: {PokemonType.fire},
          typeIdMap: typeIdMap,
          formFilter: PokedexFormFilter.all,
        );
        expect(fireResults.map((e) => e.name), ['vulpix']);

        final iceResults = PokemonIndexFilterHelper.filterAndSort(
          entries: catalog,
          selectedTypes: {PokemonType.ice},
          typeIdMap: typeIdMap,
          formFilter: PokedexFormFilter.all,
        );
        expect(iceResults.map((e) => e.name), ['vulpix-alola']);
      },
    );
  });
}
