import 'package:equatable/equatable.dart';

/// Primary trigger mechanism for Pokémon evolution.
enum EvolutionTriggerType {
  levelUp,
  useItem,
  trade,
  shed,
  spin,
  towerOfDarkness,
  towerOfWaters,
  threeCriticalHits,
  takeDamage,
  other;

  static EvolutionTriggerType fromApiName(String? name) => switch (name) {
    'level-up' => EvolutionTriggerType.levelUp,
    'use-item' => EvolutionTriggerType.useItem,
    'trade' => EvolutionTriggerType.trade,
    'shed' => EvolutionTriggerType.shed,
    'spin' => EvolutionTriggerType.spin,
    'tower-of-darkness' => EvolutionTriggerType.towerOfDarkness,
    'tower-of-waters' => EvolutionTriggerType.towerOfWaters,
    'three-critical-hits' => EvolutionTriggerType.threeCriticalHits,
    'take-damage' => EvolutionTriggerType.takeDamage,
    _ => EvolutionTriggerType.other,
  };
}

/// Details and conditions required to trigger an evolution into a specific form.
class EvolutionTriggerDetail extends Equatable {
  const EvolutionTriggerDetail({
    required this.triggerType,
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
    this.needsRain = false,
    this.gender,
    this.partySpecies,
    this.partyType,
    this.minBeauty,
    this.minAffection,
  });

  final EvolutionTriggerType triggerType;
  final int? minLevel;
  final String? item;
  final String? heldItem;
  final int? minHappiness;
  final String? timeOfDay;
  final String? location;
  final String? knownMove;
  final String? knownMoveType;
  final bool turnUpsideDown;
  final String? tradeSpecies;
  final int? relativePhysicalStats;
  final bool needsRain;
  final int? gender;
  final String? partySpecies;
  final String? partyType;
  final int? minBeauty;
  final int? minAffection;

  @override
  List<Object?> get props => [
    triggerType,
    minLevel,
    item,
    heldItem,
    minHappiness,
    timeOfDay,
    location,
    knownMove,
    knownMoveType,
    turnUpsideDown,
    tradeSpecies,
    relativePhysicalStats,
    needsRain,
    gender,
    partySpecies,
    partyType,
    minBeauty,
    minAffection,
  ];
}

/// A node in an evolution tree structure representing a specific species stage.
class EvolutionNode extends Equatable {
  const EvolutionNode({
    required this.speciesId,
    required this.speciesName,
    required this.speciesUrl,
    required this.spriteUrl,
    this.triggers = const [],
    this.evolvesTo = const [],
  });

  final int speciesId;
  final String speciesName;
  final String speciesUrl;
  final String spriteUrl;
  final List<EvolutionTriggerDetail> triggers;
  final List<EvolutionNode> evolvesTo;

  bool get isFinalStage => evolvesTo.isEmpty;

  @override
  List<Object?> get props => [
    speciesId,
    speciesName,
    speciesUrl,
    spriteUrl,
    triggers,
    evolvesTo,
  ];
}

/// Domain entity representing a complete linear or branching evolution chain.
class EvolutionChain extends Equatable {
  const EvolutionChain({required this.id, required this.root});

  final int id;
  final EvolutionNode root;

  @override
  List<Object?> get props => [id, root];
}
