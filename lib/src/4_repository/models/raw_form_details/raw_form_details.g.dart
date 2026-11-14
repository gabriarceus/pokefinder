// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_form_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawFormDetails _$RawFormDetailsFromJson(Map<String, dynamic> json) =>
    RawFormDetails(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>)
          .map((e) => TypeContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: RawFormSprites.fromJson(json['sprites'] as Map<String, dynamic>),
    );

RawFormSprites _$RawFormSpritesFromJson(Map<String, dynamic> json) =>
    RawFormSprites(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
