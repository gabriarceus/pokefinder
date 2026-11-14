// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprites.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sprites _$SpritesFromJson(Map<String, dynamic> json) => Sprites(
  frontDefault: json['front_default'] as String?,
  backDefault: json['back_default'] as String?,
  frontShiny: json['front_shiny'] as String?,
  backShiny: json['back_shiny'] as String?,
  frontFemale: json['front_female'] as String?,
  backFemale: json['back_female'] as String?,
  frontShinyFemale: json['front_shiny_female'] as String?,
  backShinyFemale: json['back_shiny_female'] as String?,
  other: json['other'] == null
      ? null
      : SpritesOther.fromJson(json['other'] as Map<String, dynamic>),
);

SpritesOther _$SpritesOtherFromJson(Map<String, dynamic> json) => SpritesOther(
  officialArtwork: json['official-artwork'] == null
      ? null
      : OfficialArtwork.fromJson(
          json['official-artwork'] as Map<String, dynamic>,
        ),
  home: json['home'] == null
      ? null
      : SpritesHome.fromJson(json['home'] as Map<String, dynamic>),
);

SpritesHome _$SpritesHomeFromJson(Map<String, dynamic> json) => SpritesHome(
  frontDefault: json['front_default'] as String?,
  frontFemale: json['front_female'] as String?,
  frontShiny: json['front_shiny'] as String?,
  frontShinyFemale: json['front_shiny_female'] as String?,
);

OfficialArtwork _$OfficialArtworkFromJson(Map<String, dynamic> json) =>
    OfficialArtwork(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
