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

void main() {
  late _MockPokemonRepository pokemonRepository;
  late _MockDataRepository dataRepository;
  late HomeBloc bloc;

  setUp(() {
    pokemonRepository = _MockPokemonRepository();
    dataRepository = _MockDataRepository();
    bloc = HomeBloc(pokemonRepository, dataRepository, _MockEnLogger());
  });

  tearDown(() => bloc.close());

  /// Seeds the name list the autocomplete suggestions are derived from.
  Future<void> seedNames(List<String> names) async {
    when(
      () => pokemonRepository.getAllPokemonNames(),
    ).thenAnswer((_) async => right(names));
    bloc.add(FetchAllPokemonNamesEvent());
    await pumpEventQueue();
  }

  group('search suggestions', () {
    test('are empty below the two-character threshold', () async {
      await seedNames(['pikachu', 'pidgey']);

      bloc.add(UserInputEvent('p'));
      await pumpEventQueue();

      expect(bloc.state.userInput, 'p');
      expect(bloc.state.searchSuggestions, isEmpty);
    });

    test('match by prefix, case-insensitively', () async {
      await seedNames(['pikachu', 'pidgey', 'raichu']);

      bloc.add(UserInputEvent('PI'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, ['pikachu', 'pidgey']);
    });

    test('exclude names that only contain the query mid-word', () async {
      await seedNames(['raichu', 'pikachu']);

      bloc.add(UserInputEvent('chu'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, isEmpty);
    });

    test('are capped at five entries', () async {
      await seedNames(List.generate(10, (i) => 'pika$i'));

      bloc.add(UserInputEvent('pika'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, hasLength(5));
    });

    test('are empty while the name list has not been loaded', () async {
      bloc.add(UserInputEvent('pika'));
      await pumpEventQueue();

      expect(bloc.state.searchSuggestions, isEmpty);
    });
  });

  group('name list loading', () {
    test('a failure leaves the state untouched', () async {
      when(
        () => pokemonRepository.getAllPokemonNames(),
      ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));

      final initialState = bloc.state;
      bloc.add(FetchAllPokemonNamesEvent());
      await pumpEventQueue();

      expect(bloc.state, initialState);
      expect(bloc.state.allPokemonNames, isEmpty);
    });
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
      expect(bloc.state.failure, isA<BadRequestFailure>());
    });

    test('typing again clears a previously surfaced failure', () async {
      bloc.add(IsButtonPressedEvent());
      await pumpEventQueue();
      expect(bloc.state.failure, isNotNull);

      bloc.add(UserInputEvent('pi'));
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
        final subscription = bloc.stream.listen(
          (state) => emitted.add(state.cacheCleared),
        );

        bloc.add(ClearCacheEvent());
        await pumpEventQueue();
        await subscription.cancel();

        verify(() => dataRepository.clearCache()).called(1);
        expect(emitted, [true, false]);
      },
    );
  });
}
