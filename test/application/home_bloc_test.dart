import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/4_repository/repositories/data_repository.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockDataRepository extends Mock implements DataRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _kSampleNames = [
  'pikachu',
  'pidgey',
  'pidgeotto',
  'pidgeot',
  'pikachu-rock-star',
  'raichu',
  'bulbasaur',
];

void main() {
  late _MockPokemonRepository pokemonRepository;
  late _MockDataRepository dataRepository;
  late _MockEnLogger logger;
  late HomeBloc bloc;

  setUp(() {
    pokemonRepository = _MockPokemonRepository();
    dataRepository = _MockDataRepository();
    logger = _MockEnLogger();
    bloc = HomeBloc(pokemonRepository, dataRepository, logger);
  });

  tearDown(() async {
    await bloc.close();
  });

  group('search suggestions', () {
    test('are empty below the two-character threshold', () async {
      when(
        () => pokemonRepository.getAllPokemonNames(),
      ).thenAnswer((_) async => right(_kSampleNames));

      bloc.add(FetchAllPokemonNamesEvent());
      await pumpEventQueue();

      bloc.add(UserInputEvent('p'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, isEmpty);
    });

    test('match by prefix, case-insensitively', () async {
      when(
        () => pokemonRepository.getAllPokemonNames(),
      ).thenAnswer((_) async => right(_kSampleNames));

      bloc.add(FetchAllPokemonNamesEvent());
      await pumpEventQueue();

      bloc.add(UserInputEvent('Pi'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, [
        'pikachu',
        'pidgey',
        'pidgeotto',
        'pidgeot',
        'pikachu-rock-star',
      ]);
    });

    test('exclude names that only contain the query mid-word', () async {
      when(
        () => pokemonRepository.getAllPokemonNames(),
      ).thenAnswer((_) async => right(_kSampleNames));

      bloc.add(FetchAllPokemonNamesEvent());
      await pumpEventQueue();

      bloc.add(UserInputEvent('chu'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, isEmpty);
    });

    test('are capped at five entries', () async {
      final manyPNames = List.generate(10, (i) => 'pkm-$i');
      when(
        () => pokemonRepository.getAllPokemonNames(),
      ).thenAnswer((_) async => right(manyPNames));

      bloc.add(FetchAllPokemonNamesEvent());
      await pumpEventQueue();

      bloc.add(UserInputEvent('pk'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions.length, 5);
    });

    test('are empty while the name list has not been loaded', () async {
      bloc.add(UserInputEvent('pika'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, isEmpty);
    });
  });

  group('name list loading', () {
    test(
      'a failure records nameIndexFailure while leaving search operable',
      () async {
        when(
          () => pokemonRepository.getAllPokemonNames(),
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
      'clears the cache and raises then lowers the confirmation flag',
      () async {
        when(() => dataRepository.clearCache()).thenAnswer((_) async {});

        final emitted = <bool>[];
        final sub = bloc.stream
            .map((s) => s.cacheCleared)
            .distinct()
            .listen(emitted.add);

        bloc.add(ClearCacheEvent());
        await pumpEventQueue();
        await sub.cancel();

        verify(() => dataRepository.clearCache()).called(1);
        expect(emitted, [true, false]);
      },
    );
  });
}
