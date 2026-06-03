import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

void main() {
  group('PokemonBlocState equality', () {
    test('initial states are equal', () {
      expect(PokemonBlocInitial(), PokemonBlocInitial());
    });

    test('loading states are equal', () {
      expect(PokemonBlocLoading(), PokemonBlocLoading());
    });

    test('failure states with equal failures are equal', () {
      expect(
        PokemonBlocFailure(BadRequestFailure()),
        PokemonBlocFailure(BadRequestFailure()),
      );
    });

    test('failure states with different failures are not equal', () {
      expect(
        PokemonBlocFailure(BadRequestFailure()),
        isNot(PokemonBlocFailure(UnauthorizedFailure())),
      );
    });
  });
}
