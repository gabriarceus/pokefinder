import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockPokemonRepository pokemonRepository;
  late _MockEnLogger logger;
  late HomeBloc bloc;

  setUp(() {
    pokemonRepository = _MockPokemonRepository();
    logger = _MockEnLogger();
    bloc = HomeBloc(pokemonRepository, logger);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state has empty fields and null failures', () {
    expect(bloc.state, HomeBlocState.initial());
    expect(bloc.state.userInput, isEmpty);
    expect(bloc.state.pokemonIndex, isEmpty);
    expect(bloc.state.isIndexLoading, isFalse);
    expect(bloc.state.searchFailure, isNull);
    expect(bloc.state.indexFailure, isNull);
    expect(bloc.state.pendingNavigation, isNull);
  });

  group('index loading', () {
    const entries = [
      PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
      PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
      PokemonIndexEntry(id: 7, name: 'squirtle', detailUrl: ''),
    ];

    test('successfully fetches the index and clears indexFailure', () async {
      when(
        () => pokemonRepository.getPokemonIndex(),
      ).thenAnswer((_) async => const Right(entries));

      bloc.add(LoadIndex());
      await pumpEventQueue();

      expect(bloc.state.pokemonIndex, entries);
      expect(bloc.state.indexFailure, isNull);
      expect(bloc.state.isIndexLoading, isFalse);
    });

    test('raises isIndexLoading before the entries arrive', () async {
      when(
        () => pokemonRepository.getPokemonIndex(),
      ).thenAnswer((_) async => const Right(entries));

      final seen = <bool>[];
      final sub = bloc.stream.map((s) => s.isIndexLoading).listen(seen.add);

      bloc.add(LoadIndex());
      await pumpEventQueue();
      await sub.cancel();

      expect(seen, [true, false]);
    });

    test(
      'a failure records indexFailure while leaving search operable',
      () async {
        when(
          () => pokemonRepository.getPokemonIndex(),
        ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));

        bloc.add(LoadIndex());
        await pumpEventQueue();

        expect(bloc.state.indexFailure, const UnexpectedFailure('offline'));
        expect(bloc.state.pokemonIndex, isEmpty);
        expect(bloc.state.isIndexLoading, isFalse);

        // Search submission remains completely operable despite index failure.
        bloc.add(SearchSubmitted('  Pikachu  '));
        await pumpEventQueue();

        expect(bloc.state.pendingNavigation, isNotNull);
        expect(bloc.state.searchFailure, isNull);
      },
    );
  });

  group('search submission', () {
    test('a valid input requests navigation and clears any failure', () async {
      bloc.add(SearchInputChanged('  Pikachu  '));
      bloc.add(SearchSubmitted('  Pikachu  '));
      await pumpEventQueue();

      expect(bloc.state.pendingNavigation?.nameOrId, 'Pikachu');
      expect(bloc.state.searchFailure, isNull);
    });

    test('trims the submitted name', () async {
      bloc.add(SearchSubmitted('   CHARIZARD   '));
      await pumpEventQueue();

      expect(bloc.state.pendingNavigation?.nameOrId, 'CHARIZARD');
      expect(bloc.state.searchFailure, isNull);
    });

    test('invalid characters surface a failure and do not navigate', () async {
      bloc.add(SearchSubmitted('pikachu!@#'));
      await pumpEventQueue();

      expect(bloc.state.pendingNavigation, isNull);
      expect(bloc.state.searchFailure, isA<BadRequestFailure>());
    });

    test('a blank input surfaces a failure instead of navigating', () async {
      bloc.add(SearchSubmitted('   '));
      await pumpEventQueue();

      expect(bloc.state.pendingNavigation, isNull);
      expect(bloc.state.searchFailure, isNotNull);
    });

    test('typing again clears a previously surfaced failure', () async {
      bloc.add(SearchSubmitted('   '));
      await pumpEventQueue();
      expect(bloc.state.searchFailure, isNotNull);

      bloc.add(SearchInputChanged('p'));
      await pumpEventQueue();

      expect(bloc.state.searchFailure, isNull);
    });

    test('repeat submission navigates again after NavigationDone', () async {
      bloc.add(SearchSubmitted('pikachu'));
      await pumpEventQueue();
      final first = bloc.state.pendingNavigation;

      // The UI consumes the request, so the next submit re-emits it.
      bloc.add(NavigationDone());
      await pumpEventQueue();
      expect(bloc.state.pendingNavigation, isNull);

      bloc.add(SearchSubmitted('pikachu'));
      await pumpEventQueue();
      final second = bloc.state.pendingNavigation;

      expect(first, isNotNull);
      expect(second, isNotNull);
      // Value equality, so a second identical submit would not be re-emitted
      // if the UI forgot to clear the request.
      expect(second, first);
    });
  });
}
