import 'package:pokefinder/src/3_domain/models/pokemon.dart';
import 'package:pokefinder/src/4_repository/services/i_pokemon_service.dart';
import 'package:dartz/dartz.dart';

class MockPokemonService implements IPokemonService {
  @override
  Future<Either<Failure, Pokemon>> getData(PokemonName pokemonName) async {
    // Mocks a network delay
    await Future.delayed(const Duration(seconds: 1));
    return const Right(Pokemon(
      id: 1,
      name: 'bulbasaur',
      sprite:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
      ability1: 'overgrow',
      ability2: 'chlorophyll',
      ability3: '',
      weight: 69,
      height: 7,
      typeImage1:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/12.png",
      typeImage2:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/4.png",
      type1: '16',
      cry:
          'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/1.ogg',
    ));
  }
}
