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
      baseExperience: (json['base_experience'] as num?)?.toInt(),
      isDefault: json['is_default'] as bool,
      order: (json['order'] as num).toInt(),
      locationAreaEncounters: json['location_area_encounters'] as String,
      forms: (json['forms'] as List<dynamic>)
          .map((e) => NamedAPIResource.fromJson(e as Map<String, dynamic>))
          .toList(),
      gameIndices: (json['game_indices'] as List<dynamic>)
          .map((e) => RawGameIndex.fromJson(e as Map<String, dynamic>))
          .toList(),
      heldItems: (json['held_items'] as List<dynamic>)
          .map((e) => RawHeldItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      moves: (json['moves'] as List<dynamic>)
          .map((e) => RawMoveContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
      species:
          NamedAPIResource.fromJson(json['species'] as Map<String, dynamic>),
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
      'base_experience': instance.baseExperience,
      'is_default': instance.isDefault,
      'order': instance.order,
      'location_area_encounters': instance.locationAreaEncounters,
      'forms': instance.forms.map((e) => e.toJson()).toList(),
      'game_indices': instance.gameIndices.map((e) => e.toJson()).toList(),
      'held_items': instance.heldItems.map((e) => e.toJson()).toList(),
      'moves': instance.moves.map((e) => e.toJson()).toList(),
      'species': instance.species.toJson(),
    };
