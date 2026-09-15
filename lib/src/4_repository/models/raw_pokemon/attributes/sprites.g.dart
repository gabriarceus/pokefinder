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

Map<String, dynamic> _$SpritesToJson(Sprites instance) => <String, dynamic>{
  'front_default': instance.frontDefault,
  'back_default': instance.backDefault,
  'front_shiny': instance.frontShiny,
  'back_shiny': instance.backShiny,
  'front_female': instance.frontFemale,
  'back_female': instance.backFemale,
  'front_shiny_female': instance.frontShinyFemale,
  'back_shiny_female': instance.backShinyFemale,
  'other': instance.other?.toJson(),
};

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

Map<String, dynamic> _$SpritesOtherToJson(SpritesOther instance) =>
    <String, dynamic>{
      'official-artwork': instance.officialArtwork?.toJson(),
      'home': instance.home?.toJson(),
    };

SpritesHome _$SpritesHomeFromJson(Map<String, dynamic> json) => SpritesHome(
  frontDefault: json['front_default'] as String?,
  frontFemale: json['front_female'] as String?,
  frontShiny: json['front_shiny'] as String?,
  frontShinyFemale: json['front_shiny_female'] as String?,
);

Map<String, dynamic> _$SpritesHomeToJson(SpritesHome instance) =>
    <String, dynamic>{
      'front_default': instance.frontDefault,
      'front_female': instance.frontFemale,
      'front_shiny': instance.frontShiny,
      'front_shiny_female': instance.frontShinyFemale,
    };

OfficialArtwork _$OfficialArtworkFromJson(Map<String, dynamic> json) =>
    OfficialArtwork(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );

Map<String, dynamic> _$OfficialArtworkToJson(OfficialArtwork instance) =>
    <String, dynamic>{
      'front_default': instance.frontDefault,
      'front_shiny': instance.frontShiny,
    };
