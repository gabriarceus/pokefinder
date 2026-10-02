import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_list_cubit/pokemon_list_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_load/pokemon_load.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockPokemonRepository repository;
  late PokemonListCubit cubit;

  setUpAll(() => registerFallbackValue(PokemonName('bulbasaur')));

  setUp(() {
    repository = _MockPokemonRepository();
    cubit = PokemonListCubit(_MockEnLogger(), repository);
  });

  tearDown(() => cubit.close());

  /// Answers `getPokemon` with the [results] entry of each requested name.
  void stubPokemon(Map<String, Either<PokemonFailure, Pokemon>> results) {
    when(() => repository.getPokemon(any())).thenAnswer(
      (invocation) async =>
          results[(invocation.positionalArguments.first as PokemonName)
              .rightOrCrash()]!,
    );
  }

  test('loads every name in order; one failure leaves the others', () async {
    final bulbasaur = buildPokemon();
    stubPokemon({
      'bulbasaur': right(bulbasaur),
      'mew': left(const NetworkUnavailableFailure('offline')),
    });

    cubit.load(['bulbasaur', 'mew']);
    expect(cubit.state, [const PokemonLoading(), const PokemonLoading()]);
    await pumpEventQueue();

    expect(cubit.state, [
      PokemonLoaded(bulbasaur),
      const PokemonLoadFailed(NetworkUnavailableFailure('offline')),
    ]);
  });

  test('retry reloads only the failed entry', () async {
    final bulbasaur = buildPokemon();
    stubPokemon({
      'bulbasaur': left(const NetworkUnavailableFailure('offline')),
    });
    cubit.load(['bulbasaur']);
    await pumpEventQueue();

    stubPokemon({'bulbasaur': right(bulbasaur)});
    cubit.retry(0);
    await pumpEventQueue();

    expect(cubit.state, [PokemonLoaded(bulbasaur)]);
    verify(() => repository.getPokemon(any())).called(2);
  });

  test('a result for a replaced list is dropped', () async {
    final pending = Completer<Either<PokemonFailure, Pokemon>>();
    final mew = buildPokemon(id: 151, name: 'mew');
    when(() => repository.getPokemon(any())).thenAnswer((invocation) {
      final name = (invocation.positionalArguments.first as PokemonName)
          .rightOrCrash();
      return name == 'mew' ? Future.value(right(mew)) : pending.future;
    });

    cubit.load(['bulbasaur']);
    cubit.load(['mew']);
    await pumpEventQueue();
    pending.complete(right(buildPokemon()));
    await pumpEventQueue();

    expect(cubit.state, [PokemonLoaded(mew)]);
  });
}
