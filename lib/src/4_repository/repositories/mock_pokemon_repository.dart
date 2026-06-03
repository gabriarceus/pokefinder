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
        type1: PokemonType.dragon,
        type2: null,
        cry:
            'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/1.ogg',
        stats: [45, 49, 49, 65, 65, 45],
        baseExperience: 64,
        isDefault: true,
        order: 1,
        locationAreaEncounters:
            'https://pokeapi.co/api/v2/pokemon/1/encounters',
        cryLegacy:
            'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/1.ogg',
        forms: [
          PokemonForm(
              name: 'bulbasaur',
              url: 'https://pokeapi.co/api/v2/pokemon-form/1/')
        ],
        gameIndices: ['red', 'blue'],
        speciesName: 'bulbasaur',
        speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
        spriteBackDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png',
        spriteFrontShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png',
        spriteBackShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png',
        officialArtworkDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
        officialArtworkShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png',
        abilities: [
          PokemonAbility(name: 'overgrow', isHidden: false, slot: 1),
          PokemonAbility(name: 'chlorophyll', isHidden: true, slot: 3),
        ],
        heldItems: [],
        moves: [],
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(
      String url) async {
    return const Right(
      PokemonFormDetails(
        name: 'bulbasaur',
        type1: PokemonType.grass,
        type2: PokemonType.poison,
        typeImage1:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/grass.png',
        typeImage2:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/poison.png',
        spriteDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        spriteShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png',
        artworkDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
        artworkShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png',
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
      String url) async {
    return const Right([
      PokemonEncounter(
        locationAreaName: 'Kanto Route 1 Area',
        rawLocationAreaName: 'kanto-route-1-area',
        versions: ['red', 'blue'],
      ),
    ]);
  }
}
