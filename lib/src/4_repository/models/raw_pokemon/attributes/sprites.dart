import 'package:json_annotation/json_annotation.dart';

part 'sprites.g.dart';

@JsonSerializable(explicitToJson: true)
class Sprites {
  const Sprites({
    this.frontDefault,
    this.backDefault,
    this.frontShiny,
    this.backShiny,
    this.frontFemale,
    this.backFemale,
    this.frontShinyFemale,
    this.backShinyFemale,
    this.other,
  });

  @JsonKey(name: 'front_default')
  final String? frontDefault;

  @JsonKey(name: 'back_default')
  final String? backDefault;

  @JsonKey(name: 'front_shiny')
  final String? frontShiny;

  @JsonKey(name: 'back_shiny')
  final String? backShiny;

  @JsonKey(name: 'front_female')
  final String? frontFemale;

  @JsonKey(name: 'back_female')
  final String? backFemale;

  @JsonKey(name: 'front_shiny_female')
  final String? frontShinyFemale;

  @JsonKey(name: 'back_shiny_female')
  final String? backShinyFemale;

  final SpritesOther? other;

  factory Sprites.fromJson(Map<String, dynamic> json) =>
      _$SpritesFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SpritesOther {
  const SpritesOther({this.officialArtwork, this.home});

  @JsonKey(name: 'official-artwork')
  final OfficialArtwork? officialArtwork;

  final SpritesHome? home;

  factory SpritesOther.fromJson(Map<String, dynamic> json) =>
      _$SpritesOtherFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesOtherToJson(this);
}

@JsonSerializable()
class SpritesHome {
  const SpritesHome({
    this.frontDefault,
    this.frontFemale,
    this.frontShiny,
    this.frontShinyFemale,
  });

  @JsonKey(name: 'front_default')
  final String? frontDefault;

  @JsonKey(name: 'front_female')
  final String? frontFemale;

  @JsonKey(name: 'front_shiny')
  final String? frontShiny;

  @JsonKey(name: 'front_shiny_female')
  final String? frontShinyFemale;

  factory SpritesHome.fromJson(Map<String, dynamic> json) =>
      _$SpritesHomeFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesHomeToJson(this);
}

@JsonSerializable()
class OfficialArtwork {
  const OfficialArtwork({this.frontDefault, this.frontShiny});

  @JsonKey(name: 'front_default')
  final String? frontDefault;

  @JsonKey(name: 'front_shiny')
  final String? frontShiny;

  factory OfficialArtwork.fromJson(Map<String, dynamic> json) =>
      _$OfficialArtworkFromJson(json);

  Map<String, dynamic> toJson() => _$OfficialArtworkToJson(this);
}
