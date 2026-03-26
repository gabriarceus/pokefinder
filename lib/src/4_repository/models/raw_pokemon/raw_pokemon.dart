import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/abilities/ability_container.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/cries.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/sprites.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/types/type_container.dart';

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
    required this.weight,
    required this.height,
    required this.cries,
  });

  final int id;
  final String name;
  final List<TypeContainer> types;
  final Sprites sprites;
  final List<AbilityContainer> abilities;
  final Cries cries;

  /// In hectograms
  final double weight;

  /// In decimetres
  final double height;

  factory RawPokemon.fromJson(Map<String, dynamic> json) =>
      _$RawPokemonFromJson(json);

  Map<String, dynamic> toJson() => _$RawPokemonToJson(this);
}
