// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_pokemon_species.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawPokemonSpecies _$RawPokemonSpeciesFromJson(
  Map<String, dynamic> json,
) => RawPokemonSpecies(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  generation: json['generation'] == null
      ? null
      : NamedAPIResource.fromJson(json['generation'] as Map<String, dynamic>),
  habitat: json['habitat'] == null
      ? null
      : NamedAPIResource.fromJson(json['habitat'] as Map<String, dynamic>),
  captureRate: (json['capture_rate'] as num?)?.toInt(),
  baseHappiness: (json['base_happiness'] as num?)?.toInt(),
  growthRate: json['growth_rate'] == null
      ? null
      : NamedAPIResource.fromJson(json['growth_rate'] as Map<String, dynamic>),
  genderRate: (json['gender_rate'] as num?)?.toInt(),
  eggGroups:
      (json['egg_groups'] as List<dynamic>?)
          ?.map((e) => NamedAPIResource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  evolutionChain: json['evolution_chain'] == null
      ? null
      : RawEvolutionChainResource.fromJson(
          json['evolution_chain'] as Map<String, dynamic>,
        ),
  flavorTextEntries:
      (json['flavor_text_entries'] as List<dynamic>?)
          ?.map(
            (e) =>
                RawSpeciesFlavorTextEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  genera:
      (json['genera'] as List<dynamic>?)
          ?.map((e) => RawSpeciesGenusEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isBaby: json['is_baby'] as bool? ?? false,
  isLegendary: json['is_legendary'] as bool? ?? false,
  isMythical: json['is_mythical'] as bool? ?? false,
);

Map<String, dynamic> _$RawPokemonSpeciesToJson(RawPokemonSpecies instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'generation': instance.generation?.toJson(),
      'habitat': instance.habitat?.toJson(),
      'capture_rate': instance.captureRate,
      'base_happiness': instance.baseHappiness,
      'growth_rate': instance.growthRate?.toJson(),
      'gender_rate': instance.genderRate,
      'egg_groups': instance.eggGroups.map((e) => e.toJson()).toList(),
      'evolution_chain': instance.evolutionChain?.toJson(),
      'flavor_text_entries': instance.flavorTextEntries
          .map((e) => e.toJson())
          .toList(),
      'genera': instance.genera.map((e) => e.toJson()).toList(),
      'is_baby': instance.isBaby,
      'is_legendary': instance.isLegendary,
      'is_mythical': instance.isMythical,
    };

RawEvolutionChainResource _$RawEvolutionChainResourceFromJson(
  Map<String, dynamic> json,
) => RawEvolutionChainResource(url: json['url'] as String);

Map<String, dynamic> _$RawEvolutionChainResourceToJson(
  RawEvolutionChainResource instance,
) => <String, dynamic>{'url': instance.url};

RawSpeciesFlavorTextEntry _$RawSpeciesFlavorTextEntryFromJson(
  Map<String, dynamic> json,
) => RawSpeciesFlavorTextEntry(
  flavorText: json['flavor_text'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
  version: json['version'] == null
      ? null
      : NamedAPIResource.fromJson(json['version'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RawSpeciesFlavorTextEntryToJson(
  RawSpeciesFlavorTextEntry instance,
) => <String, dynamic>{
  'flavor_text': instance.flavorText,
  'language': instance.language.toJson(),
  'version': instance.version?.toJson(),
};

RawSpeciesGenusEntry _$RawSpeciesGenusEntryFromJson(
  Map<String, dynamic> json,
) => RawSpeciesGenusEntry(
  genus: json['genus'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RawSpeciesGenusEntryToJson(
  RawSpeciesGenusEntry instance,
) => <String, dynamic>{
  'genus': instance.genus,
  'language': instance.language.toJson(),
};
