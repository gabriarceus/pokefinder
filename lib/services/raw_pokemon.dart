import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/services/raw_pokemon_attributes/abilities/ability_container.dart';
import 'package:pokefinder/services/raw_pokemon_attributes/cries.dart';
import 'package:pokefinder/services/raw_pokemon_attributes/sprites.dart';
import 'package:pokefinder/services/raw_pokemon_attributes/types/type_container.dart';

part 'raw_pokemon.g.dart';

/// Pokémon repository (dati sporchi)
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

  /// in ettogrammi
  final double weight;

  /// in decimetri
  final double height;

  factory RawPokemon.fromJson(Map<String, dynamic> json) =>
      _$RawPokemonFromJson(json);

  Map<String, dynamic> toJson() => _$RawPokemonToJson(this);
}
