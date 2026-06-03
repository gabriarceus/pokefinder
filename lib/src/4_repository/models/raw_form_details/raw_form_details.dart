import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/types/type_container.dart';

part 'raw_form_details.g.dart';

/// Raw data for a single Pokémon form, parsed from the form endpoint.
@JsonSerializable(explicitToJson: true)
class RawFormDetails {
  const RawFormDetails({
    required this.id,
    required this.name,
    required this.types,
    required this.sprites,
  });

  final int id;
  final String name;
  final List<TypeContainer> types;
  final RawFormSprites sprites;

  factory RawFormDetails.fromJson(Map<String, dynamic> json) =>
      _$RawFormDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$RawFormDetailsToJson(this);
}

/// Sprite URLs for a Pokémon form.
@JsonSerializable()
class RawFormSprites {
  const RawFormSprites({
    required this.frontDefault,
    required this.frontShiny,
  });

  @JsonKey(name: 'front_default')
  final String frontDefault;

  @JsonKey(name: 'front_shiny')
  final String frontShiny;

  factory RawFormSprites.fromJson(Map<String, dynamic> json) =>
      _$RawFormSpritesFromJson(json);

  Map<String, dynamic> toJson() => _$RawFormSpritesToJson(this);
}
