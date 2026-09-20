// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_evolution_chain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawEvolutionChain _$RawEvolutionChainFromJson(Map<String, dynamic> json) =>
    RawEvolutionChain(
      id: (json['id'] as num).toInt(),
      chain: RawChainLink.fromJson(json['chain'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RawEvolutionChainToJson(RawEvolutionChain instance) =>
    <String, dynamic>{'id': instance.id, 'chain': instance.chain.toJson()};

RawChainLink _$RawChainLinkFromJson(Map<String, dynamic> json) => RawChainLink(
  isBaby: json['is_baby'] as bool? ?? false,
  species: NamedAPIResource.fromJson(json['species'] as Map<String, dynamic>),
  evolutionDetails:
      (json['evolution_details'] as List<dynamic>?)
          ?.map((e) => RawEvolutionDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  evolvesTo:
      (json['evolves_to'] as List<dynamic>?)
          ?.map((e) => RawChainLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RawChainLinkToJson(RawChainLink instance) =>
    <String, dynamic>{
      'is_baby': instance.isBaby,
      'species': instance.species.toJson(),
      'evolution_details': instance.evolutionDetails
          .map((e) => e.toJson())
          .toList(),
      'evolves_to': instance.evolvesTo.map((e) => e.toJson()).toList(),
    };

RawEvolutionDetail _$RawEvolutionDetailFromJson(
  Map<String, dynamic> json,
) => RawEvolutionDetail(
  trigger: json['trigger'] == null
      ? null
      : NamedAPIResource.fromJson(json['trigger'] as Map<String, dynamic>),
  minLevel: (json['min_level'] as num?)?.toInt(),
  item: json['item'] == null
      ? null
      : NamedAPIResource.fromJson(json['item'] as Map<String, dynamic>),
  heldItem: json['held_item'] == null
      ? null
      : NamedAPIResource.fromJson(json['held_item'] as Map<String, dynamic>),
  minHappiness: (json['min_happiness'] as num?)?.toInt(),
  timeOfDay: json['time_of_day'] as String?,
  location: json['location'] == null
      ? null
      : NamedAPIResource.fromJson(json['location'] as Map<String, dynamic>),
  knownMove: json['known_move'] == null
      ? null
      : NamedAPIResource.fromJson(json['known_move'] as Map<String, dynamic>),
  knownMoveType: json['known_move_type'] == null
      ? null
      : NamedAPIResource.fromJson(
          json['known_move_type'] as Map<String, dynamic>,
        ),
  turnUpsideDown: json['turn_upside_down'] as bool? ?? false,
  tradeSpecies: json['trade_species'] == null
      ? null
      : NamedAPIResource.fromJson(
          json['trade_species'] as Map<String, dynamic>,
        ),
  relativePhysicalStats: (json['relative_physical_stats'] as num?)?.toInt(),
  needsOverworldRain: json['needs_overworld_rain'] as bool? ?? false,
  gender: (json['gender'] as num?)?.toInt(),
  partySpecies: json['party_species'] == null
      ? null
      : NamedAPIResource.fromJson(
          json['party_species'] as Map<String, dynamic>,
        ),
  partyType: json['party_type'] == null
      ? null
      : NamedAPIResource.fromJson(json['party_type'] as Map<String, dynamic>),
  minBeauty: (json['min_beauty'] as num?)?.toInt(),
  minAffection: (json['min_affection'] as num?)?.toInt(),
);

Map<String, dynamic> _$RawEvolutionDetailToJson(RawEvolutionDetail instance) =>
    <String, dynamic>{
      'trigger': instance.trigger?.toJson(),
      'min_level': instance.minLevel,
      'item': instance.item?.toJson(),
      'held_item': instance.heldItem?.toJson(),
      'min_happiness': instance.minHappiness,
      'time_of_day': instance.timeOfDay,
      'location': instance.location?.toJson(),
      'known_move': instance.knownMove?.toJson(),
      'known_move_type': instance.knownMoveType?.toJson(),
      'turn_upside_down': instance.turnUpsideDown,
      'trade_species': instance.tradeSpecies?.toJson(),
      'relative_physical_stats': instance.relativePhysicalStats,
      'needs_overworld_rain': instance.needsOverworldRain,
      'gender': instance.gender,
      'party_species': instance.partySpecies?.toJson(),
      'party_type': instance.partyType?.toJson(),
      'min_beauty': instance.minBeauty,
      'min_affection': instance.minAffection,
    };
