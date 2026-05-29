import 'package:equatable/equatable.dart';

/// Domain model for a Pokemon
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.sprite,
    required this.ability1,
    required this.ability2,
    required this.ability3,
    required this.weight,
    required this.height,
    required this.typeImage1,
    required this.typeImage2,
    required this.type1,
    required this.type2,
    required this.cry,
    required this.stats,
    required this.baseExperience,
    required this.isDefault,
    required this.order,
    required this.locationAreaEncounters,
    required this.cryLegacy,
    required this.forms,
    required this.gameIndices,
    required this.speciesName,
    required this.speciesUrl,
    required this.spriteBackDefault,
    required this.spriteFrontShiny,
    required this.spriteBackShiny,
    required this.officialArtworkDefault,
    required this.officialArtworkShiny,
    required this.abilities,
    required this.heldItems,
    required this.moves,
  });

  final int id;
  final String name;
  final String typeImage1;
  final String typeImage2;
  final String type1;
  final String? type2;
  final String sprite;
  final String ability1;
  final String ability2;
  final String ability3;
  final String cry;

  /// [weight] is the weight of the Pokemon in hectograms
  final double weight;

  /// [height] is the height of the Pokemon in decimetres
  final double height;

  /// [stats] is a list of base stats in the order: HP, Attack, Defense, Special Attack, Special Defense, Speed
  final List<int> stats;

  final int? baseExperience;
  final bool isDefault;
  final int order;
  final String locationAreaEncounters;
  final String? cryLegacy;
  final List<PokemonForm> forms;
  final List<String> gameIndices;
  final String speciesName;
  final String speciesUrl;
  final String? spriteBackDefault;
  final String? spriteFrontShiny;
  final String? spriteBackShiny;
  final String? officialArtworkDefault;
  final String? officialArtworkShiny;
  final List<PokemonAbility> abilities;
  final List<PokemonHeldItem> heldItems;
  final List<PokemonMove> moves;

  @override
  List<Object?> get props => [
        id,
        name,
        sprite,
        ability1,
        ability2,
        ability3,
        weight,
        height,
        typeImage1,
        typeImage2,
        type1,
        type2,
        cry,
        stats,
        baseExperience,
        isDefault,
        order,
        locationAreaEncounters,
        cryLegacy,
        forms,
        gameIndices,
        speciesName,
        speciesUrl,
        spriteBackDefault,
        spriteFrontShiny,
        spriteBackShiny,
        officialArtworkDefault,
        officialArtworkShiny,
        abilities,
        heldItems,
        moves,
      ];
}

class PokemonAbility extends Equatable {
  const PokemonAbility({
    required this.name,
    required this.isHidden,
    required this.slot,
  });

  final String name;
  final bool isHidden;
  final int slot;

  @override
  List<Object?> get props => [name, isHidden, slot];
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
  });

  final String name;
  final String url;

  @override
  List<Object?> get props => [name, url];
}

class PokemonFormDetails extends Equatable {
  const PokemonFormDetails({
    required this.name,
    required this.type1,
    this.type2,
    required this.typeImage1,
    required this.typeImage2,
    required this.spriteDefault,
    required this.spriteShiny,
    required this.artworkDefault,
    required this.artworkShiny,
  });

  final String name;
  final String type1;
  final String? type2;
  final String typeImage1;
  final String typeImage2;
  final String spriteDefault;
  final String spriteShiny;
  final String artworkDefault;
  final String artworkShiny;

  @override
  List<Object?> get props => [
        name,
        type1,
        type2,
        typeImage1,
        typeImage2,
        spriteDefault,
        spriteShiny,
        artworkDefault,
        artworkShiny,
      ];
}

class PokemonEncounter extends Equatable {
  const PokemonEncounter({
    required this.locationAreaName,
    required this.rawLocationAreaName,
    required this.versions,
  });

  final String locationAreaName;
  final String rawLocationAreaName;
  final List<String> versions;

  @override
  List<Object?> get props => [locationAreaName, rawLocationAreaName, versions];
}
