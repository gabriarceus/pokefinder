import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_load/pokemon_load.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

const _bulbasaur = PokemonIndexEntry(
  id: 1,
  name: 'bulbasaur',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
  types: [PokemonType.grass, PokemonType.poison],
);
const _charmander = PokemonIndexEntry(
  id: 4,
  name: 'charmander',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
  types: [PokemonType.fire],
);
const _squirtle = PokemonIndexEntry(
  id: 7,
  name: 'squirtle',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
  types: [PokemonType.water],
);

void main() {
  late _MockEnLogger logger;
  late _MockPokemonRepository repository;

  // ComparisonCubit loads the details of every entry through a PokemonName.
  setUpAll(() => registerFallbackValue(PokemonName('bulbasaur')));

  setUp(() {
    logger = _MockEnLogger();
    repository = _MockPokemonRepository();
    when(
      () => repository.getPokemon(any()),
    ).thenAnswer((_) async => right(buildPokemon()));
  });

  ComparisonCubit buildCubit() => ComparisonCubit(logger, repository);

  group('ComparisonCubit', () {
    for (final clearSelection in [false, true]) {
      test(
        '${clearSelection ? 'clear' : 'remove'} and re-add discard the previous request',
        () async {
          final first = Completer<Either<PokemonFailure, Pokemon>>();
          final second = Completer<Either<PokemonFailure, Pokemon>>();
          var calls = 0;
          when(
            () => repository.getPokemon(any()),
          ).thenAnswer((_) => ++calls == 1 ? first.future : second.future);
          final cubit = buildCubit();
          addTearDown(cubit.close);

          cubit.addEntry(_bulbasaur.summary);
          if (clearSelection) {
            cubit.clear();
          } else {
            cubit.removeEntry(_bulbasaur.id);
          }
          cubit.addEntry(_bulbasaur.summary);

          final pokemon = buildPokemon();
          second.complete(right(pokemon));
          await pumpEventQueue();
          expect(
            cubit.state.detailOf(_bulbasaur.summary),
            PokemonLoaded(pokemon),
          );

          first.complete(left(const NetworkUnavailableFailure('obsolete')));
          await pumpEventQueue();
          expect(
            cubit.state.detailOf(_bulbasaur.summary),
            PokemonLoaded(pokemon),
          );
        },
      );
    }

    test(
      'a retry discards a previous request for the same selection',
      () async {
        final first = Completer<Either<PokemonFailure, Pokemon>>();
        final second = Completer<Either<PokemonFailure, Pokemon>>();
        var calls = 0;
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) => ++calls == 1 ? first.future : second.future);
        final cubit = buildCubit();
        addTearDown(cubit.close);
        cubit.addEntry(_bulbasaur.summary);
        final retry = cubit.loadDetails(_bulbasaur.summary);

        first.complete(left(const NetworkUnavailableFailure('obsolete')));
        await pumpEventQueue();
        expect(
          cubit.state.detailOf(_bulbasaur.summary),
          const PokemonLoading(),
        );

        final pokemon = buildPokemon();
        second.complete(right(pokemon));
        await retry;
        expect(
          cubit.state.detailOf(_bulbasaur.summary),
          PokemonLoaded(pokemon),
        );
      },
    );

    test('addEntry stores entries in insertion order', () {
      final cubit = buildCubit();

      expect(cubit.addEntry(_bulbasaur.summary), isTrue);
      expect(cubit.addEntry(_charmander.summary), isTrue);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([1, 4]),
      );
      expect(cubit.state.isFull, isTrue);
    });

    test('addEntry enforces the max-2 cap and keeps existing entries', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      cubit.addEntry(_charmander.summary);

      expect(cubit.addEntry(_squirtle.summary), isFalse);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([1, 4]),
      );
      expect(cubit.isSelected(7), isFalse);
    });

    test('addEntry ignores duplicates', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);

      expect(cubit.addEntry(_bulbasaur.summary), isFalse);
      expect(cubit.state.entries.length, equals(1));
    });

    test('removeEntry removes only the matching entry', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      cubit.addEntry(_charmander.summary);

      cubit.removeEntry(1);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([4]),
      );
      expect(cubit.isSelected(1), isFalse);
      expect(cubit.isSelected(4), isTrue);
    });

    test('removeEntry ignores unknown ids', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);

      cubit.removeEntry(999);

      expect(cubit.state.entries.length, equals(1));
    });

    test('toggleEntry adds then removes the same entry', () {
      final cubit = buildCubit();

      expect(cubit.toggleEntry(_bulbasaur.summary), isTrue);
      expect(cubit.isSelected(1), isTrue);

      expect(cubit.toggleEntry(_bulbasaur.summary), isFalse);
      expect(cubit.isSelected(1), isFalse);
      expect(cubit.state.entries, isEmpty);
    });

    test('toggleEntry refuses a third entry while full', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      cubit.addEntry(_charmander.summary);

      expect(cubit.toggleEntry(_squirtle.summary), isFalse);
      expect(cubit.state.entries.length, equals(2));
    });

    test('clear removes all entries', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      cubit.addEntry(_charmander.summary);

      cubit.clear();

      expect(cubit.state.entries, isEmpty);
      expect(cubit.state.isFull, isFalse);
    });

    test('entries hold lightweight summaries only', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);

      final stored = cubit.state.entries.single;
      expect(stored, isA<PokemonSummary>());
      expect(stored.id, equals(1));
      expect(stored.name, equals('bulbasaur'));
    });

    test('a new entry is loading until its details arrive', () async {
      final cubit = buildCubit();

      cubit.addEntry(_bulbasaur.summary);
      expect(cubit.state.detailOf(_bulbasaur.summary), const PokemonLoading());

      await pumpEventQueue();
      expect(cubit.state.detailOf(_bulbasaur.summary), isA<PokemonLoaded>());
    });

    test('addEntry requests the details of the added entry', () async {
      final cubit = buildCubit();

      cubit.addEntry(_bulbasaur.summary);
      await pumpEventQueue();

      final captured = verify(
        () => repository.getPokemon(captureAny()),
      ).captured;
      expect(captured.length, 1);
      expect(captured.single, isA<PokemonName>());
      expect((captured.single as PokemonName).rightOrCrash(), 'bulbasaur');
    });

    test('a failing load marks only the failing entry as failed', () async {
      when(() => repository.getPokemon(any())).thenAnswer((invocation) {
        final name = (invocation.positionalArguments.first as PokemonName)
            .rightOrCrash();
        if (name == 'charmander') {
          return Future.value(left(const NetworkUnavailableFailure('offline')));
        }
        return Future.value(right(buildPokemon()));
      });

      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      cubit.addEntry(_charmander.summary);
      await pumpEventQueue();

      expect(
        cubit.state.detailOf(_charmander.summary),
        const PokemonLoadFailed(NetworkUnavailableFailure('offline')),
      );
      expect(cubit.state.detailOf(_bulbasaur.summary), isA<PokemonLoaded>());
    });

    test('removing an entry drops its loaded details', () async {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur.summary);
      await pumpEventQueue();
      expect(cubit.state.details.containsKey(1), isTrue);

      cubit.removeEntry(1);

      expect(cubit.state.details.containsKey(1), isFalse);
    });

    test(
      'a load that resolves after the entry was removed is discarded',
      () async {
        final cubit = buildCubit();
        cubit.addEntry(_bulbasaur.summary);
        cubit.removeEntry(1);

        await pumpEventQueue();

        expect(cubit.state.details, isEmpty);
      },
    );
  });
}
