import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_pokemon.g.dart';

/// Pokémon repository (raw data)
/// This class is used to parse the JSON data from the API
/// into a [RawPokemon] object.
@JsonSerializable(explicitToJson: true)
class RawPokemon {
  const RawPokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.sprites,
    required this.abilities,
    required this.stats,
    required this.weight,
    required this.height,
    required this.cries,
    required this.baseExperience,
    required this.isDefault,
    required this.order,
    required this.locationAreaEncounters,
    required this.forms,
    required this.gameIndices,
    required this.heldItems,
    required this.moves,
    required this.species,
  });

  final int id;
  final String name;
  final List<TypeContainer> types;
  final Sprites sprites;
  final List<AbilityContainer> abilities;
  final List<StatContainer> stats;
  final Cries cries;

  /// In hectograms
  final double weight;

  /// In decimetres
  final double height;

  @JsonKey(name: 'base_experience')
  final int? baseExperience;

  @JsonKey(name: 'is_default')
  final bool isDefault;

  final int order;

  @JsonKey(name: 'location_area_encounters')
  final String locationAreaEncounters;

  final List<NamedAPIResource> forms;

  @JsonKey(name: 'game_indices')
  final List<RawGameIndex> gameIndices;

  @JsonKey(name: 'held_items')
  final List<RawHeldItem> heldItems;

  final List<RawMoveContainer> moves;

  final NamedAPIResource species;

  factory RawPokemon.fromJson(Map<String, dynamic> json) =>
      _$RawPokemonFromJson(json);

  Map<String, dynamic> toJson() => _$RawPokemonToJson(this);
}
