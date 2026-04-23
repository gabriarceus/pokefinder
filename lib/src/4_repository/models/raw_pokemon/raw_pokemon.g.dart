// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawPokemon _$RawPokemonFromJson(Map<String, dynamic> json) => RawPokemon(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>)
          .map((e) => TypeContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: Sprites.fromJson(json['sprites'] as Map<String, dynamic>),
      abilities: (json['abilities'] as List<dynamic>)
          .map((e) => AbilityContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List<dynamic>)
          .map((e) => StatContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      cries: Cries.fromJson(json['cries'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RawPokemonToJson(RawPokemon instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'types': instance.types.map((e) => e.toJson()).toList(),
      'sprites': instance.sprites.toJson(),
      'abilities': instance.abilities.map((e) => e.toJson()).toList(),
      'stats': instance.stats.map((e) => e.toJson()).toList(),
      'cries': instance.cries.toJson(),
      'weight': instance.weight,
      'height': instance.height,
    };
