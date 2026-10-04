import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late PokedexBloc bloc;

  final sampleEntries = [
    const PokemonIndexEntry(
      id: 1,
      name: 'bulbasaur',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
      types: [PokemonType.grass, PokemonType.poison],
    ),
    const PokemonIndexEntry(
      id: 4,
      name: 'charmander',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
      types: [PokemonType.fire],
    ),
    const PokemonIndexEntry(
      id: 7,
      name: 'squirtle',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
      types: [PokemonType.water],
    ),
    const PokemonIndexEntry(
      id: 25,
      name: 'pikachu',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
      types: [PokemonType.electric],
    ),
  ];

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    bloc = PokedexBloc(
      repository,
      logger,
      searchDebounceDuration: Duration.zero,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('PokedexFetchIndexEvent', () {
    test('successful fetch updates state to success with entries', () async {
      when(
        () => repository.getPokemonIndex(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      expect(bloc.state.status, PokedexStatus.success);
      expect(bloc.state.allEntries, sampleEntries);
      expect(bloc.state.filteredEntries, sampleEntries);
      expect(bloc.state.failure, isNull);
    });

    test(
      'the whole index is exposed at once, without in-memory paging',
      () async {
        final manyEntries = List.generate(
          80,
          (i) => PokemonIndexEntry(
            id: i + 1,
            name: 'pokemon-${i + 1}',
            detailUrl: '',
          ),
        );

        when(
          () => repository.getPokemonIndex(
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right(manyEntries));

        bloc.add(const PokedexFetchIndexEvent());
        await pumpEventQueue();

        expect(bloc.state.allEntries.length, 80);
        expect(bloc.state.filteredEntries, manyEntries);
      },
    );

    test('failure on empty catalog sets failure status', () async {
      when(
        () => repository.getPokemonIndex(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => left(const NetworkUnavailableFailure('No internet')),
      );

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      expect(bloc.state.status, PokedexStatus.failure);
      expect(bloc.state.failure, isA<NetworkUnavailableFailure>());
    });

    test('failure during pull-to-refresh preserves existing entries', () async {
      when(
        () => repository.getPokemonIndex(forceRefresh: false),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent(forceRefresh: false));
      await pumpEventQueue();
      expect(bloc.state.allEntries.length, 4);

      // Now simulate refresh failure
      when(() => repository.getPokemonIndex(forceRefresh: true)).thenAnswer(
        (_) async => left(const NetworkUnavailableFailure('No internet')),
      );

      bloc.add(const PokedexFetchIndexEvent(forceRefresh: true));
      await pumpEventQueue();

      expect(bloc.state.status, PokedexStatus.success);
      expect(bloc.state.allEntries.length, 4);
      // The grid is still usable, so the refresh failure must not pin the
      // offline banner for the rest of the session.
      expect(bloc.state.failure, isNull);
      expect(bloc.state.isRefreshing, isFalse);
    });
  });

  group('Filtering and Search', () {
    setUp(() async {
      when(
        () => repository.getPokemonIndex(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();
    });

    test('search query updates filteredEntries', () async {
      bloc.add(const PokedexSearchQueryChangedEvent('pika'));
      await pumpEventQueue();

      expect(bloc.state.filters.query, 'pika');
      expect(bloc.state.filteredEntries.map((e) => e.name), ['pikachu']);
    });

    test('type filter toggles type and queries type IDs if missing', () async {
      when(
        () => repository.getPokemonIdsForType(PokemonType.fire),
      ).thenAnswer((_) async => const Right({4}));

      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();

      expect(bloc.state.filters.selectedTypes, {PokemonType.fire});
      expect(bloc.state.typeIdMap[PokemonType.fire], {4});
      expect(bloc.state.loadingTypes, isEmpty);
      expect(bloc.state.filteredEntries.map((e) => e.name), ['charmander']);

      // Untoggle
      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();

      expect(bloc.state.filters.selectedTypes, isEmpty);
      expect(bloc.state.filteredEntries.length, 4);
    });

    test(
      'a selected type is shown right away and marked loading until its ids arrive',
      () async {
        final completer = Completer<Either<PokemonFailure, Set<int>>>();
        when(
          () => repository.getPokemonIdsForType(PokemonType.fire),
        ).thenAnswer((_) => completer.future);

        bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
        await pumpEventQueue();

        // The selection is emitted before the ids are known...
        expect(bloc.state.filters.selectedTypes, {PokemonType.fire});
        expect(bloc.state.loadingTypes, {PokemonType.fire});
        // ...and the grid keeps the entries it already had meanwhile.
        expect(bloc.state.filteredEntries, sampleEntries);

        completer.complete(const Right({4}));
        await pumpEventQueue();

        expect(bloc.state.loadingTypes, isEmpty);
        expect(bloc.state.filters.selectedTypes, {PokemonType.fire});
        expect(bloc.state.typeIdMap, {
          PokemonType.fire: {4},
        });
        expect(bloc.state.typeFilterFailure, isNull);
        expect(bloc.state.filteredEntries.map((e) => e.name), ['charmander']);
      },
    );

    test(
      'propagates failure when getPokemonIdsForType fails: the type is deselected '
      'and the failure surfaces on typeFilterFailure',
      () async {
        when(
          () => repository.getPokemonIdsForType(PokemonType.fire),
        ).thenAnswer(
          (_) async => left(const NetworkUnavailableFailure('Network error')),
        );

        bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
        await pumpEventQueue();

        expect(bloc.state.filters.selectedTypes, isEmpty);
        expect(bloc.state.loadingTypes, isEmpty);
        expect(bloc.state.typeIdMap, isEmpty);
        expect(
          bloc.state.typeFilterFailure,
          const NetworkUnavailableFailure('Network error'),
        );
        // The index failure channel stays untouched: the catalog is still there.
        expect(bloc.state.failure, isNull);
        expect(bloc.state.status, PokedexStatus.success);
        expect(bloc.state.filteredEntries, sampleEntries);
      },
    );

    test(
      'a query sent while a type loads is kept when the type load fails',
      () async {
        final completer = Completer<Either<PokemonFailure, Set<int>>>();
        when(
          () => repository.getPokemonIdsForType(PokemonType.fire),
        ).thenAnswer((_) => completer.future);

        bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
        await pumpEventQueue();
        bloc.add(const PokedexSearchQueryChangedEvent('s'));
        await pumpEventQueue();
        // No Fire Pokémon contains "s" in the sample.
        expect(bloc.state.filteredEntries, isEmpty);

        completer.complete(
          left(const NetworkUnavailableFailure('No internet')),
        );
        await pumpEventQueue();

        expect(bloc.state.filters.selectedTypes, isEmpty);
        expect(bloc.state.filteredEntries.map((e) => e.name), [
          'bulbasaur',
          'squirtle',
        ]);
      },
    );

    test(
      'a second tap on a loading type cancels it: one request, no failure',
      () async {
        final completer = Completer<Either<PokemonFailure, Set<int>>>();
        when(
          () => repository.getPokemonIdsForType(PokemonType.fire),
        ).thenAnswer((_) => completer.future);

        bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
        await pumpEventQueue();
        bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
        await pumpEventQueue();

        expect(bloc.state.filters.selectedTypes, isEmpty);
        expect(bloc.state.loadingTypes, isEmpty);

        completer.complete(
          left(const NetworkUnavailableFailure('No internet')),
        );
        await pumpEventQueue();

        expect(bloc.state.filters.selectedTypes, isEmpty);
        expect(bloc.state.typeFilterFailure, isNull);
        expect(bloc.state.filteredEntries, sampleEntries);
        verify(
          () => repository.getPokemonIdsForType(PokemonType.fire),
        ).called(1);
      },
    );

    test('debounces consecutive search queries when duration > 0', () async {
      final debouncedBloc = PokedexBloc(
        repository,
        logger,
        searchDebounceDuration: const Duration(milliseconds: 50),
      );
      when(
        () => repository.getPokemonIndex(
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      debouncedBloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      debouncedBloc.add(const PokedexSearchQueryChangedEvent('p'));
      debouncedBloc.add(const PokedexSearchQueryChangedEvent('pi'));
      debouncedBloc.add(const PokedexSearchQueryChangedEvent('pik'));

      // Immediately after dispatch, query has not debounced yet
      expect(debouncedBloc.state.filters.query, isEmpty);

      // Wait for debounce duration
      await Future<void>.delayed(const Duration(milliseconds: 75));
      expect(debouncedBloc.state.filters.query, 'pik');

      await debouncedBloc.close();
    });

    test('generation filter filters entries by generation', () async {
      bloc.add(const PokedexGenerationFilterChangedEvent(2));
      await pumpEventQueue();

      expect(bloc.state.filters.generation, 2);
      expect(
        bloc.state.filteredEntries,
        isEmpty,
      ); // All sample entries are Gen 1

      bloc.add(const PokedexGenerationFilterChangedEvent(1));
      await pumpEventQueue();
      expect(bloc.state.filteredEntries.length, 4);
    });

    test('sort order change reorders entries', () async {
      bloc.add(
        const PokedexSortOrderChangedEvent(PokedexSortOrder.nameAscending),
      );
      await pumpEventQueue();

      expect(bloc.state.filters.sortOrder, PokedexSortOrder.nameAscending);
      expect(bloc.state.filteredEntries.map((e) => e.name), [
        'bulbasaur',
        'charmander',
        'pikachu',
        'squirtle',
      ]);
    });

    test('clear filters resets all filters to default', () async {
      bloc.add(const PokedexSearchQueryChangedEvent('pika'));
      bloc.add(const PokedexGenerationFilterChangedEvent(1));
      bloc.add(
        const PokedexSortOrderChangedEvent(PokedexSortOrder.nameAscending),
      );
      await pumpEventQueue();
      expect(bloc.state.filters.hasActiveFilters, isTrue);

      bloc.add(const PokedexClearFiltersEvent());
      await pumpEventQueue();

      expect(bloc.state.filters.hasActiveFilters, isFalse);
      expect(bloc.state.filters, const PokedexFilters());
      expect(bloc.state.filters.query, isEmpty);
      expect(bloc.state.filters.selectedTypes, isEmpty);
      expect(bloc.state.filters.generation, isNull);
      expect(bloc.state.filters.sortOrder, PokedexSortOrder.idAscending);
      expect(bloc.state.filteredEntries.length, 4);
    });

    test('clear ignores late type failures', () async {
      final pending = Completer<Either<PokemonFailure, Set<int>>>();
      when(
        () => repository.getPokemonIdsForType(PokemonType.fire),
      ).thenAnswer((_) => pending.future);
      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();
      bloc.add(const PokedexClearFiltersEvent());
      await pumpEventQueue();
      expect(bloc.state.loadingTypes, isEmpty);
      pending.complete(left(const NetworkUnavailableFailure()));
      await pumpEventQueue();
      expect(bloc.state.typeFilterFailure, isNull);
      expect(bloc.state.filters.selectedTypes, isEmpty);
    });

    test('clear then reselect keeps the new type request active', () async {
      final first = Completer<Either<PokemonFailure, Set<int>>>();
      final second = Completer<Either<PokemonFailure, Set<int>>>();
      var calls = 0;
      when(
        () => repository.getPokemonIdsForType(PokemonType.fire),
      ).thenAnswer((_) => ++calls == 1 ? first.future : second.future);
      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();
      bloc.add(const PokedexClearFiltersEvent());
      await pumpEventQueue();
      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();
      first.complete(left(const NetworkUnavailableFailure()));
      await pumpEventQueue();
      expect(bloc.state.loadingTypes, {PokemonType.fire});
      expect(bloc.state.filters.selectedTypes, {PokemonType.fire});
      expect(bloc.state.typeFilterFailure, isNull);
      second.complete(right({4}));
      await pumpEventQueue();
      expect(bloc.state.loadingTypes, isEmpty);
      expect(bloc.state.filters.selectedTypes, {PokemonType.fire});
      expect(bloc.state.filteredEntries.map((entry) => entry.id), [4]);
    });
  });

  group('Random Pokemon & Forms', () {
    test(
      'select random pokemon picks from pool and handles navigation reset',
      () async {
        when(
          () => repository.getPokemonIndex(
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => Right(sampleEntries));

        bloc.add(const PokedexFetchIndexEvent());
        await pumpEventQueue();

        bloc.add(const PokedexSelectRandomPokemonEvent());
        await pumpEventQueue();

        expect(bloc.state.randomPokemonToNavigate, isNotNull);
        expect(
          sampleEntries.contains(bloc.state.randomPokemonToNavigate!),
          isTrue,
        );

        bloc.add(const PokedexRandomNavigationDoneEvent());
        await pumpEventQueue();

        expect(bloc.state.randomPokemonToNavigate, isNull);
      },
    );

    group('Form filtering in PokedexBloc', () {
      final mixedEntries = [
        const PokemonIndexEntry(id: 3, name: 'venusaur', detailUrl: ''),
        const PokemonIndexEntry(
          id: 10033,
          name: 'venusaur-mega',
          detailUrl: '',
          parentSpeciesId: 3,
          formCategory: PokemonFormCategory.mega,
        ),
        const PokemonIndexEntry(
          id: 10103,
          name: 'vulpix-alola',
          detailUrl: '',
          parentSpeciesId: 37,
          formCategory: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
        ),
        const PokemonIndexEntry(
          id: 10094,
          name: 'pikachu-original-cap',
          detailUrl: '',
          parentSpeciesId: 25,
          formCategory: PokemonFormCategory.cosmetic,
        ),
      ];

      test(
        'toggles formFilter and updates filteredEntries accordingly',
        () async {
          when(
            () => repository.getPokemonIndex(
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => Right(mixedEntries));

          bloc.add(const PokedexFetchIndexEvent());
          await pumpEventQueue();

          // Default: canonical only
          expect(bloc.state.filteredEntries.map((e) => e.name), ['venusaur']);

          // Switch to all forms
          bloc.add(const PokedexFormFilterChangedEvent(PokedexFormFilter.all));
          await pumpEventQueue();
          expect(bloc.state.filteredEntries.map((e) => e.name), [
            'venusaur',
            'venusaur-mega',
            'vulpix-alola',
          ]);

          // Switch to Mega only
          bloc.add(const PokedexFormFilterChangedEvent(PokedexFormFilter.mega));
          await pumpEventQueue();
          expect(bloc.state.filteredEntries.map((e) => e.name), [
            'venusaur-mega',
          ]);

          // Switch to Regional only
          bloc.add(
            const PokedexFormFilterChangedEvent(PokedexFormFilter.regional),
          );
          await pumpEventQueue();
          expect(bloc.state.filteredEntries.map((e) => e.name), [
            'vulpix-alola',
          ]);

          // Enable cosmetics toggle
          bloc.add(const PokedexFormFilterChangedEvent(PokedexFormFilter.all));
          bloc.add(const PokedexCosmeticToggleChangedEvent(true));
          await pumpEventQueue();
          expect(bloc.state.filteredEntries.map((e) => e.name), [
            'venusaur',
            'venusaur-mega',
            'pikachu-original-cap',
            'vulpix-alola',
          ]);
        },
      );
    });
  });
}
