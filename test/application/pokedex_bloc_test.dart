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

  test('initial state has correct defaults', () {
    expect(bloc.state.status, PokedexStatus.initial);
    expect(bloc.state.allEntries, isEmpty);
    expect(bloc.state.filteredEntries, isEmpty);
    expect(bloc.state.visibleEntries, isEmpty);
    expect(bloc.state.searchQuery, isEmpty);
    expect(bloc.state.selectedTypes, isEmpty);
    expect(bloc.state.selectedGeneration, isNull);
    expect(bloc.state.sortOrder, PokedexSortOrder.idAscending);
    expect(bloc.state.failure, isNull);
  });

  group('PokedexFetchIndexEvent', () {
    test('successful fetch updates state to success with entries', () async {
      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      expect(bloc.state.status, PokedexStatus.success);
      expect(bloc.state.allEntries, sampleEntries);
      expect(bloc.state.filteredEntries, sampleEntries);
      expect(bloc.state.visibleEntries, sampleEntries);
      expect(bloc.state.failure, isNull);
    });

    test('failure on empty catalog sets failure status', () async {
      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
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
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: false,
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent(forceRefresh: false));
      await pumpEventQueue();
      expect(bloc.state.allEntries.length, 4);

      // Now simulate refresh failure
      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: true,
        ),
      ).thenAnswer(
        (_) async => left(const NetworkUnavailableFailure('No internet')),
      );

      bloc.add(const PokedexFetchIndexEvent(forceRefresh: true));
      await pumpEventQueue();

      expect(bloc.state.status, PokedexStatus.success);
      expect(bloc.state.allEntries.length, 4);
      expect(bloc.state.failure, isA<NetworkUnavailableFailure>());
      expect(bloc.state.isRefreshing, isFalse);
    });
  });

  group('Filtering and Search', () {
    setUp(() async {
      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();
    });

    test('search query updates filteredEntries and visibleEntries', () async {
      bloc.add(const PokedexSearchQueryChangedEvent('pika'));
      await pumpEventQueue();

      expect(bloc.state.searchQuery, 'pika');
      expect(bloc.state.filteredEntries.map((e) => e.name), ['pikachu']);
    });

    test('type filter toggles type and queries type IDs if missing', () async {
      when(
        () => repository.getPokemonIdsForType(
          PokemonType.fire,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Right({4}));

      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();

      expect(bloc.state.selectedTypes, {PokemonType.fire});
      expect(bloc.state.filteredEntries.map((e) => e.name), ['charmander']);

      // Untoggle
      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();

      expect(bloc.state.selectedTypes, isEmpty);
      expect(bloc.state.filteredEntries.length, 4);
    });

    test('propagates failure when getPokemonIdsForType fails', () async {
      when(
        () => repository.getPokemonIdsForType(
          PokemonType.fire,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => left(const NetworkUnavailableFailure('Network error')),
      );

      bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire));
      await pumpEventQueue();

      expect(bloc.state.selectedTypes, {PokemonType.fire});
      expect(bloc.state.failure, isA<NetworkUnavailableFailure>());
    });

    test('debounces consecutive search queries when duration > 0', () async {
      final debouncedBloc = PokedexBloc(
        repository,
        logger,
        searchDebounceDuration: const Duration(milliseconds: 50),
      );
      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(sampleEntries));

      debouncedBloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      debouncedBloc.add(const PokedexSearchQueryChangedEvent('p'));
      debouncedBloc.add(const PokedexSearchQueryChangedEvent('pi'));
      debouncedBloc.add(const PokedexSearchQueryChangedEvent('pik'));

      // Immediately after dispatch, query has not debounced yet
      expect(debouncedBloc.state.searchQuery, isEmpty);

      // Wait for debounce duration
      await Future<void>.delayed(const Duration(milliseconds: 75));
      expect(debouncedBloc.state.searchQuery, 'pik');

      await debouncedBloc.close();
    });

    test('generation filter filters entries by generation', () async {
      bloc.add(const PokedexGenerationFilterChangedEvent(2));
      await pumpEventQueue();

      expect(bloc.state.selectedGeneration, 2);
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

      expect(bloc.state.sortOrder, PokedexSortOrder.nameAscending);
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
      expect(bloc.state.hasActiveFilters, isTrue);

      bloc.add(const PokedexClearFiltersEvent());
      await pumpEventQueue();

      expect(bloc.state.hasActiveFilters, isFalse);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.selectedTypes, isEmpty);
      expect(bloc.state.selectedGeneration, isNull);
      expect(bloc.state.sortOrder, PokedexSortOrder.idAscending);
      expect(bloc.state.filteredEntries.length, 4);
    });
  });

  group('Pagination & Random Pokemon', () {
    test('load more increases visible entries when hasMore is true', () async {
      final manyEntries = List.generate(
        50,
        (i) => PokemonIndexEntry(
          id: i + 1,
          name: 'pokemon-${i + 1}',
          detailUrl: '',
        ),
      );

      when(
        () => repository.getPokemonIndex(
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(manyEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      expect(bloc.state.visibleEntries.length, 24);
      expect(bloc.state.hasMore, isTrue);

      bloc.add(const PokedexLoadMoreEvent());
      await pumpEventQueue();

      expect(bloc.state.visibleEntries.length, 48);
      expect(bloc.state.currentPage, 2);
    });

    test('concurrent load more events are handled cleanly', () async {
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
          cancelToken: any(named: 'cancelToken'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => Right(manyEntries));

      bloc.add(const PokedexFetchIndexEvent());
      await pumpEventQueue();

      bloc.add(const PokedexLoadMoreEvent());
      bloc.add(const PokedexLoadMoreEvent());
      await pumpEventQueue();

      expect(bloc.state.currentPage, 2);
    });

    test(
      'select random pokemon picks from pool and handles navigation reset',
      () async {
        when(
          () => repository.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
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
              cancelToken: any(named: 'cancelToken'),
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
