import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_evolution_chain.g.dart';

@JsonSerializable(explicitToJson: true)
class RawEvolutionChain {
  const RawEvolutionChain({required this.id, required this.chain});

  final int id;
  final RawChainLink chain;

  factory RawEvolutionChain.fromJson(Map<String, dynamic> json) =>
      _$RawEvolutionChainFromJson(json);

  Map<String, dynamic> toJson() => _$RawEvolutionChainToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawChainLink {
  const RawChainLink({
    this.isBaby = false,
    required this.species,
    this.evolutionDetails = const [],
    this.evolvesTo = const [],
  });

  @JsonKey(name: 'is_baby')
  final bool isBaby;
  final NamedAPIResource species;

  @JsonKey(name: 'evolution_details')
  final List<RawEvolutionDetail> evolutionDetails;

  @JsonKey(name: 'evolves_to')
  final List<RawChainLink> evolvesTo;

  factory RawChainLink.fromJson(Map<String, dynamic> json) =>
      _$RawChainLinkFromJson(json);

  Map<String, dynamic> toJson() => _$RawChainLinkToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawEvolutionDetail {
  const RawEvolutionDetail({
    this.trigger,
    this.minLevel,
    this.item,
    this.heldItem,
    this.minHappiness,
    this.timeOfDay,
    this.location,
    this.knownMove,
    this.knownMoveType,
    this.turnUpsideDown = false,
    this.tradeSpecies,
    this.relativePhysicalStats,
    this.needsOverworldRain = false,
    this.gender,
    this.partySpecies,
    this.partyType,
    this.minBeauty,
    this.minAffection,
  });

  final NamedAPIResource? trigger;

  @JsonKey(name: 'min_level')
  final int? minLevel;

  final NamedAPIResource? item;

  @JsonKey(name: 'held_item')
  final NamedAPIResource? heldItem;

  @JsonKey(name: 'min_happiness')
  final int? minHappiness;

  @JsonKey(name: 'time_of_day')
  final String? timeOfDay;

  final NamedAPIResource? location;

  @JsonKey(name: 'known_move')
  final NamedAPIResource? knownMove;

  @JsonKey(name: 'known_move_type')
  final NamedAPIResource? knownMoveType;

  @JsonKey(name: 'turn_upside_down')
  final bool turnUpsideDown;

  @JsonKey(name: 'trade_species')
  final NamedAPIResource? tradeSpecies;

  @JsonKey(name: 'relative_physical_stats')
  final int? relativePhysicalStats;

  @JsonKey(name: 'needs_overworld_rain')
  final bool needsOverworldRain;

  final int? gender;

  @JsonKey(name: 'party_species')
  final NamedAPIResource? partySpecies;

  @JsonKey(name: 'party_type')
  final NamedAPIResource? partyType;

  @JsonKey(name: 'min_beauty')
  final int? minBeauty;

  @JsonKey(name: 'min_affection')
  final int? minAffection;

  factory RawEvolutionDetail.fromJson(Map<String, dynamic> json) =>
      _$RawEvolutionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawEvolutionDetailToJson(this);
}
