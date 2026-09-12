import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/usecases/clear_cache_usecase.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockClearCacheUseCase extends Mock implements ClearCacheUseCase {}

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockPokemonRepository pokemonRepository;
  late _MockClearCacheUseCase clearCacheUseCase;
  late _MockEnLogger logger;
  late HomeBloc bloc;

  setUp(() {
    pokemonRepository = _MockPokemonRepository();
    clearCacheUseCase = _MockClearCacheUseCase();
    logger = _MockEnLogger();
    bloc = HomeBloc(pokemonRepository, clearCacheUseCase, logger);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state has empty fields and null failures', () {
    expect(bloc.state, HomeBlocState.initial());
    expect(bloc.state.userInput, isEmpty);
    expect(bloc.state.allPokemonNames, isEmpty);
    expect(bloc.state.nameIndexFailure, isNull);
    expect(bloc.state.failure, isNull);
    expect(bloc.state.navigateToDetail, isFalse);
    expect(bloc.state.cacheCleared, isFalse);
  });

  group('name list loading', () {
    test(
      'successfully fetches names, updates allPokemonNames, and clears nameIndexFailure',
      () async {
        const entries = [
          PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
          PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
          PokemonIndexEntry(id: 7, name: 'squirtle', detailUrl: ''),
        ];
        when(
          () => pokemonRepository.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => const Right(entries));

        bloc.add(FetchAllPokemonNamesEvent());
        await pumpEventQueue();

        expect(bloc.state.allPokemonNames, [
          'bulbasaur',
          'charmander',
          'squirtle',
        ]);
        expect(bloc.state.pokemonIndex, entries);
        expect(bloc.state.nameIndexFailure, isNull);
      },
    );

    test(
      'a failure records nameIndexFailure while leaving search operable',
      () async {
        when(
          () => pokemonRepository.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));

        bloc.add(FetchAllPokemonNamesEvent());
        await pumpEventQueue();

        expect(bloc.state.nameIndexFailure, const UnexpectedFailure('offline'));
        expect(bloc.state.allPokemonNames, isEmpty);

        // Verify search submission remains completely operable despite index failure
        bloc.add(UserInputEvent('  Pikachu  '));
        bloc.add(IsButtonPressedEvent());
        await pumpEventQueue();

        expect(bloc.state.navigateToDetail, isTrue);
        expect(bloc.state.failure, isNull);
      },
    );
  });

  group('search submission', () {
    test('a valid input requests navigation and clears any failure', () async {
      bloc.add(UserInputEvent('  Pikachu  '));
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();

      expect(bloc.state.navigateToDetail, isTrue);
      expect(bloc.state.failure, isNull);
    });

    test(
      'normalizes input with surrounding whitespace and capital letters to navigate',
      () async {
        bloc.add(UserInputEvent('   CHARIZARD   '));
        bloc.add(IsButtonPressedEvent());
        await pumpEventQueue();

        expect(bloc.state.navigateToDetail, isTrue);
        expect(bloc.state.failure, isNull);
      },
    );

    test('invalid characters surface a failure and do not navigate', () async {
      bloc.add(UserInputEvent('pikachu!@#'));
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();

      expect(bloc.state.navigateToDetail, isFalse);
      expect(bloc.state.failure, isA<BadRequestFailure>());
    });

    test('a blank input surfaces a failure instead of navigating', () async {
      bloc.add(UserInputEvent('   '));
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();

      expect(bloc.state.navigateToDetail, isFalse);
      expect(bloc.state.failure, isNotNull);
    });

    test('typing again clears a previously surfaced failure', () async {
      bloc.add(UserInputEvent('   '));
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();
      expect(bloc.state.failure, isNotNull);

      bloc.add(UserInputEvent('p'));
      await pumpEventQueue();

      expect(bloc.state.failure, isNull);
    });

    test('NavigationDoneEvent lowers the navigation flag', () async {
      bloc.add(UserInputEvent('pikachu'));
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();
      expect(bloc.state.navigateToDetail, isTrue);

      bloc.add(NavigationDoneEvent());
      await pumpEventQueue();

      expect(bloc.state.navigateToDetail, isFalse);
    });
  });

  group('cache clearing', () {
    test(
      'clears the cache and raises then lowers the confirmation flag on success',
      () async {
        when(
          () => clearCacheUseCase(),
        ).thenAnswer((_) async => const Right(unit));

        final emitted = <bool>[];
        final sub = bloc.stream
            .map((s) => s.cacheCleared)
            .distinct()
            .listen(emitted.add);

        bloc.add(ClearCacheEvent());
        await pumpEventQueue();
        await sub.cancel();

        verify(() => clearCacheUseCase()).called(1);
        expect(emitted, [true, false]);
        expect(bloc.state.failure, isNull);
      },
    );

    test('surfaces failure when cache clearing fails', () async {
      when(() => clearCacheUseCase()).thenAnswer(
        (_) async => const Left(StorageFailure('Failed to clear storage')),
      );

      bloc.add(ClearCacheEvent());
      await pumpEventQueue();

      verify(() => clearCacheUseCase()).called(1);
      expect(bloc.state.cacheCleared, isFalse);
      expect(
        bloc.state.failure,
        const StorageFailure('Failed to clear storage'),
      );
    });
  });
}
