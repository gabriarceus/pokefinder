import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

@LazySingleton(as: IPokemonRepository, env: ['mock'])
class MockPokemonRepository implements IPokemonRepository {
  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) async {
    await Future.delayed(const Duration(seconds: 1));

    return const Right(
      Pokemon(
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
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/12.png',
        typeImage2:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/4.png',
        type1: '16',
        type2: null,
        cry:
            'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/1.ogg',
        stats: [45, 49, 49, 65, 65, 45],
      ),
    );
  }
}
