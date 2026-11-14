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
);

RawEvolutionChainResource _$RawEvolutionChainResourceFromJson(
  Map<String, dynamic> json,
) => RawEvolutionChainResource(url: json['url'] as String);

RawSpeciesFlavorTextEntry _$RawSpeciesFlavorTextEntryFromJson(
  Map<String, dynamic> json,
) => RawSpeciesFlavorTextEntry(
  flavorText: json['flavor_text'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
  version: json['version'] == null
      ? null
      : NamedAPIResource.fromJson(json['version'] as Map<String, dynamic>),
);

RawSpeciesGenusEntry _$RawSpeciesGenusEntryFromJson(
  Map<String, dynamic> json,
) => RawSpeciesGenusEntry(
  genus: json['genus'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
);
