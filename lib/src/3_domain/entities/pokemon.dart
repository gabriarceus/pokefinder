import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_sprites.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Domain model for a Pokemon
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.sprite,
    required this.weight,
    required this.height,
    required this.type1,
    required this.type2,
    required this.cry,
    required this.stats,
    required this.baseExperience,
    required this.isDefault,
    required this.locationAreaEncounters,
    required this.cryLegacy,
    required this.forms,
    required this.gameIndices,
    required this.speciesName,
    required this.speciesUrl,
    required this.sprites,
    required this.abilities,
    required this.heldItems,
    required this.moves,
    this.isStale = false,
  });

  final int id;
  final String name;
  final PokemonType? type1;
  final PokemonType? type2;
  final String sprite;
  final String cry;

  /// Weight in hectograms (as returned by PokeAPI).
  final double weight;

  /// Height in decimetres (as returned by PokeAPI).
  final double height;

  double get weightInKg => weight / 10;
  double get heightInMeters => height / 10;

  /// [stats] is a list of base stats in the order: HP, Attack, Defense, Special Attack, Special Defense, Speed
  final List<int> stats;

  final int? baseExperience;
  final bool isDefault;
  final String locationAreaEncounters;
  final String? cryLegacy;
  final List<PokemonForm> forms;
  final List<String> gameIndices;
  final String speciesName;
  final String speciesUrl;
  final PokemonSprites sprites;
  final List<PokemonAbility> abilities;
  final List<PokemonHeldItem> heldItems;
  final List<PokemonMove> moves;
  final bool isStale;

  @override
  List<Object?> get props => [
    id,
    name,
    sprite,
    weight,
    height,
    type1,
    type2,
    cry,
    stats,
    baseExperience,
    isDefault,
    locationAreaEncounters,
    cryLegacy,
    forms,
    gameIndices,
    speciesName,
    speciesUrl,
    sprites,
    abilities,
    heldItems,
    moves,
    isStale,
  ];
}

class PokemonAbility extends Equatable {
  const PokemonAbility({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;

  @override
  List<Object?> get props => [name, isHidden];
}

class PokemonHeldItem extends Equatable {
  const PokemonHeldItem({
    required this.name,
    required this.rarity,
    required this.version,
  });

  final String name;
  final int rarity;
  final String version;

  @override
  List<Object?> get props => [name, rarity, version];
}

class PokemonMove extends Equatable {
  const PokemonMove({
    required this.name,
    required this.levelLearnedAt,
    required this.learnMethod,
    required this.versionGroup,
  });

  final String name;
  final int levelLearnedAt;
  final String learnMethod;
  final String versionGroup;

  @override
  List<Object?> get props => [name, levelLearnedAt, learnMethod, versionGroup];
}

class PokemonForm extends Equatable {
  const PokemonForm({
    required this.name,
    required this.url,
    this.type1,
    this.type2,
  });

  final String name;
  final String url;
  final PokemonType? type1;
  final PokemonType? type2;

  @override
  List<Object?> get props => [name, url, type1, type2];
}

class PokemonFormDetails extends Equatable {
  const PokemonFormDetails({
    required this.name,
    required this.type1,
    this.type2,
    required this.spriteDefault,
    required this.spriteShiny,
    required this.artworkDefault,
    required this.artworkShiny,
  });

  /// Builds the default form details from a [Pokemon]'s own attributes,
  /// falling back to the base sprite when shiny/artwork variants are missing.
  factory PokemonFormDetails.fromPokemon(Pokemon pokemon) => PokemonFormDetails(
    name: pokemon.name,
    type1: pokemon.type1,
    type2: pokemon.type2,
    spriteDefault: pokemon.sprite,
    spriteShiny: pokemon.sprites.frontShiny ?? pokemon.sprite,
    artworkDefault: pokemon.sprites.artworkDefault ?? pokemon.sprite,
    artworkShiny:
        pokemon.sprites.artworkShiny ??
        pokemon.sprites.frontShiny ??
        pokemon.sprite,
  );

  final String name;
  final PokemonType? type1;
  final PokemonType? type2;
  final String spriteDefault;
  final String spriteShiny;
  final String artworkDefault;
  final String artworkShiny;

  @override
  List<Object?> get props => [
    name,
    type1,
    type2,
    spriteDefault,
    spriteShiny,
    artworkDefault,
    artworkShiny,
  ];
}

class PokemonEncounter extends Equatable {
  const PokemonEncounter({
    required this.rawLocationAreaName,
    required this.versions,
  });

  final String rawLocationAreaName;
  final List<String> versions;

  @override
  List<Object?> get props => [rawLocationAreaName, versions];
}
