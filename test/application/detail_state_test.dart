import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

final _fakePokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  sprite: '',
  ability1: '',
  ability2: '',
  ability3: '',
  weight: 69,
  height: 7,
  typeImage1: '',
  typeImage2: '',
  type1: null,
  type2: null,
  cry: '',
  stats: const [],
  baseExperience: null,
  isDefault: true,
  order: 1,
  locationAreaEncounters: '',
  cryLegacy: null,
  forms: const [],
  gameIndices: const [],
  speciesName: 'bulbasaur',
  speciesUrl: '',
  spriteBackDefault: null,
  spriteFrontShiny: null,
  spriteBackShiny: null,
  officialArtworkDefault: null,
  officialArtworkShiny: null,
  abilities: const [],
  heldItems: const [],
  moves: const [],
);

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

  group('PokemonBlocSuccess.copyWith sentinel', () {
    test('copyWith(formFailure: null) zeroes a non-null formFailure', () {
      final state = PokemonBlocSuccess(
        pokemon: _fakePokemon,
        formFailure: BadRequestFailure(),
      );
      expect(state.copyWith(formFailure: null).formFailure, isNull);
    });

    test(
        'copyWith(encountersFailure: null) zeroes a non-null encountersFailure',
        () {
      final state = PokemonBlocSuccess(
        pokemon: _fakePokemon,
        encountersFailure: UnexpectedFailure('oops'),
      );
      expect(state.copyWith(encountersFailure: null).encountersFailure, isNull);
    });

    test('copyWith() without failure args preserves existing failures', () {
      final failure = BadRequestFailure();
      final state =
          PokemonBlocSuccess(pokemon: _fakePokemon, formFailure: failure);
      expect(state.copyWith(isLoadingForm: false).formFailure, same(failure));
    });
  });
}
