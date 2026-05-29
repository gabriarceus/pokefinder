import 'package:json_annotation/json_annotation.dart';

part 'sprites.g.dart';

@JsonSerializable(explicitToJson: true)
class Sprites {
  const Sprites({
    required this.frontDefault,
    required this.backDefault,
    required this.frontShiny,
    required this.backShiny,
    required this.other,
  });

  @JsonKey(name: 'front_default')
  final String frontDefault;

  @JsonKey(name: 'back_default')
  final String? backDefault;

  @JsonKey(name: 'front_shiny')
  final String? frontShiny;

  @JsonKey(name: 'back_shiny')
  final String? backShiny;

  final SpritesOther? other;

  factory Sprites.fromJson(Map<String, dynamic> json) =>
      _$SpritesFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SpritesOther {
  const SpritesOther({
    required this.officialArtwork,
  });

  @JsonKey(name: 'official-artwork')
  final OfficialArtwork officialArtwork;

  factory SpritesOther.fromJson(Map<String, dynamic> json) =>
      _$SpritesOtherFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesOtherToJson(this);
}

@JsonSerializable()
class OfficialArtwork {
  const OfficialArtwork({
    required this.frontDefault,
    required this.frontShiny,
  });

  @JsonKey(name: 'front_default')
  final String frontDefault;

  @JsonKey(name: 'front_shiny')
  final String frontShiny;

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) =>
      _$OfficialArtworkFromJson(json);

  Map<String, dynamic> toJson() => _$OfficialArtworkToJson(this);
}
