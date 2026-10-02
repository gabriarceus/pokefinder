import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

import '../fixtures/pokemon_fixture.dart';

final _fakePokemon = buildPokemon();

void main() {
  group('PokemonDetailSuccess.copyWith sentinel', () {
    test('copyWith(formFailure: null) zeroes a non-null formFailure', () {
      final state = PokemonDetailSuccess(
        pokemon: _fakePokemon,
        formFailure: BadRequestFailure(),
      );
      expect(state.copyWith(formFailure: null).formFailure, isNull);
    });

    test(
      'copyWith(encountersFailure: null) zeroes a non-null encountersFailure',
      () {
        final state = PokemonDetailSuccess(
          pokemon: _fakePokemon,
          encountersFailure: UnexpectedFailure('oops'),
        );
        expect(
          state.copyWith(encountersFailure: null).encountersFailure,
          isNull,
        );
      },
    );

    test('copyWith() without failure args preserves existing failures', () {
      final failure = BadRequestFailure();
      final state = PokemonDetailSuccess(
        pokemon: _fakePokemon,
        formFailure: failure,
      );
      expect(state.copyWith(isLoadingForm: false).formFailure, same(failure));
    });
  });
}
