import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_sprites.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_summary.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Builds a [Pokemon] with placeholder values for every field not overridden.
Pokemon buildPokemon({
  int id = 1,
  String name = 'bulbasaur',
  String sprite = 'sprite.png',
  PokemonType? type1 = PokemonType.grass,
  PokemonType? type2,
  String locationAreaEncounters =
      'https://pokeapi.co/api/v2/pokemon/1/encounters',
  List<PokemonForm> forms = const [],
  List<PokemonMove> moves = const [],
  List<PokemonHeldItem> heldItems = const [],
  List<String> gameIndices = const [],
  PokemonSprites sprites = const PokemonSprites(),
  bool isStale = false,
  List<int> stats = const [45, 49, 49, 65, 65, 45],
  double weight = 69,
  double height = 7,
  String cry = 'cry.ogg',
  String? speciesName,
  List<PokemonAbility> abilities = const [],
}) {
  return Pokemon(
    id: id,
    name: name,
    sprite: sprite,
    weight: weight,
    height: height,
    type1: type1,
    type2: type2,
    cry: cry,
    stats: stats,
    baseExperience: 64,
    isDefault: true,
    locationAreaEncounters: locationAreaEncounters,
    cryLegacy: null,
    forms: forms,
    gameIndices: gameIndices,
    speciesName: speciesName ?? name,
    speciesUrl: '',
    sprites: sprites,
    abilities: abilities,
    heldItems: heldItems,
    moves: moves,
    isStale: isStale,
  );
}

/// Builds a [PokemonSummary] with placeholder values.
PokemonSummary buildSummary({
  int id = 1,
  String name = 'bulbasaur',
  String spriteUrl = 'sprite.png',
  List<PokemonType> types = const [PokemonType.grass],
  int? parentSpeciesId,
  String? parentSpeciesName,
  PokemonFormCategory formCategory = PokemonFormCategory.canonical,
  PokemonRegionalGroup? regionalGroup,
}) {
  return PokemonSummary(
    id: id,
    name: name,
    spriteUrl: spriteUrl,
    types: types,
    parentSpeciesId: parentSpeciesId,
    parentSpeciesName: parentSpeciesName,
    formCategory: formCategory,
    regionalGroup: regionalGroup,
  );
}
