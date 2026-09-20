import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

@LazySingleton(as: IPokemonRepository, env: [Environment.dev, 'mock'])
class MockPokemonRepository implements IPokemonRepository {
  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(
    PokemonName name, {
    CancellationToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return const Right(
      Pokemon(
        id: 1,
        name: 'bulbasaur',
        sprite:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        weight: 69,
        height: 7,
        typeImage1:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/12.png',
        typeImage2:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/4.png',
        type1: PokemonType.grass,
        type2: PokemonType.poison,
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
            url: 'https://pokeapi.co/api/v2/pokemon-form/1/',
          ),
        ],
        gameIndices: ['red', 'blue'],
        speciesName: 'bulbasaur',
        speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
        spriteBackDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png',
        spriteFrontDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
        spriteFrontShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png',
        spriteBackShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png',
        spriteFrontFemale: null,
        spriteBackFemale: null,
        spriteFrontShinyFemale: null,
        spriteBackShinyFemale: null,
        officialArtworkDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
        officialArtworkShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/1.png',
        homeDefault:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/1.png',
        homeFemale: null,
        homeShiny:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/1.png',
        homeShinyFemale: null,
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
    String url, {
    CancellationToken? cancelToken,
  }) async {
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
    String url, {
    CancellationToken? cancelToken,
  }) async {
    return const Right([
      PokemonEncounter(
        locationAreaName: 'Kanto Route 1 Area',
        rawLocationAreaName: 'kanto-route-1-area',
        versions: ['red', 'blue'],
      ),
    ]);
  }

  @override
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    CancellationToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    return const Right([
      PokemonIndexEntry(
        id: 1,
        name: 'bulbasaur',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
        types: [PokemonType.grass, PokemonType.poison],
      ),
      PokemonIndexEntry(
        id: 2,
        name: 'ivysaur',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/2/',
        types: [PokemonType.grass, PokemonType.poison],
      ),
      PokemonIndexEntry(
        id: 3,
        name: 'venusaur',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/3/',
        types: [PokemonType.grass, PokemonType.poison],
      ),
      PokemonIndexEntry(
        id: 4,
        name: 'charmander',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
        types: [PokemonType.fire],
      ),
      PokemonIndexEntry(
        id: 25,
        name: 'pikachu',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
        types: [PokemonType.electric],
      ),
    ]);
  }

  @override
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type, {
    CancellationToken? cancelToken,
  }) async {
    return switch (type) {
      PokemonType.grass => const Right({1, 2, 3}),
      PokemonType.poison => const Right({1, 2, 3}),
      PokemonType.fire => const Right({4}),
      PokemonType.electric => const Right({25}),
      PokemonType.normal ||
      PokemonType.fighting ||
      PokemonType.flying ||
      PokemonType.ground ||
      PokemonType.rock ||
      PokemonType.bug ||
      PokemonType.ghost ||
      PokemonType.steel ||
      PokemonType.water ||
      PokemonType.psychic ||
      PokemonType.ice ||
      PokemonType.dragon ||
      PokemonType.dark ||
      PokemonType.fairy ||
      PokemonType.stellar => const Right({}),
    };
  }

  @override
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames() async {
    final indexResult = await getPokemonIndex();
    return indexResult.map((entries) => entries.map((e) => e.name).toList());
  }

  @override
  Future<Either<PokemonFailure, MoveDetail>> getMoveDetail(
    String name, {
    CancellationToken? cancelToken,
  }) async {
    return Right(
      MoveDetail(
        id: 1,
        name: name,
        accuracy: 100,
        power: 40,
        pp: 35,
        type: PokemonType.normal,
        damageClass: DamageClass.physical,
        flavorTexts: const {
          'en': 'Pounds with fore­legs or tail.',
          'it': 'Colpisce il bersaglio con la coda o le zampe anteriori.',
        },
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonSpecies>> getPokemonSpecies(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    return const Right(
      PokemonSpecies(
        id: 1,
        name: 'bulbasaur',
        flavorTexts: [
          PokemonSpeciesFlavorText(
            text:
                'A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.',
            language: 'en',
            version: 'red',
          ),
          PokemonSpeciesFlavorText(
            text:
                'Alla nascita gli è stato piantato un seme strano sul dorso. Il seme cresce insieme al corpo.',
            language: 'it',
            version: 'sword',
          ),
        ],
        genera: {'en': 'Seed Pokémon', 'it': 'Pokémon Seme'},
        generation: 'generation-i',
        habitat: 'grassland',
        captureRate: 45,
        baseHappiness: 50,
        growthRate: 'medium-slow',
        genderRate: 1,
        eggGroups: ['monster', 'plant'],
        evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, EvolutionChain>> getEvolutionChain(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    return const Right(
      EvolutionChain(
        id: 1,
        root: EvolutionNode(
          speciesId: 1,
          speciesName: 'bulbasaur',
          speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
          spriteUrl:
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
          evolvesTo: [
            EvolutionNode(
              speciesId: 2,
              speciesName: 'ivysaur',
              speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/2/',
              spriteUrl:
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png',
              triggers: [
                EvolutionTriggerDetail(
                  triggerType: EvolutionTriggerType.levelUp,
                  minLevel: 16,
                ),
              ],
              evolvesTo: [
                EvolutionNode(
                  speciesId: 3,
                  speciesName: 'venusaur',
                  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/3/',
                  spriteUrl:
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png',
                  triggers: [
                    EvolutionTriggerDetail(
                      triggerType: EvolutionTriggerType.levelUp,
                      minLevel: 32,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, AbilityDetail>> getAbilityDetail(
    String name, {
    CancellationToken? cancelToken,
  }) async {
    return const Right(
      AbilityDetail(
        id: 65,
        name: 'overgrow',
        flavorTexts: {
          'en': 'Ups GRASS moves in a pinch.',
          'it': 'Potenzia le mosse di tipo Erba in situazioni critiche.',
        },
        effects: {
          'en':
              'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× as much regular damage.',
          'it':
              'Quando i PS sono a 1/3 o meno, la potenza delle mosse di tipo Erba aumenta del 50%.',
        },
        shortEffects: {
          'en':
              'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
          'it':
              'Potenzia le mosse di tipo Erba quando i PS scendono sotto 1/3.',
        },
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, Unit>> clearCache() async {
    return const Right(unit);
  }

  @override
  Future<Either<PokemonFailure, int>> getCacheSize() async {
    return const Right(512 * 1024);
  }
}
