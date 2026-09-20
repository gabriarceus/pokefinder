import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Canonical 18-type effectiveness chart (Generation VI onward).
///
/// Rows are attacking types, columns are defending types. Generation IX uses
/// the same 18-type multipliers; Stellar is excluded because it has no stable
/// defensive profile and the task targets the classic 18 types.
class TypeMatchupChart {
  const TypeMatchupChart._();

  /// Battle types covered by the chart, in display order.
  static const List<PokemonType> battleTypes = [
    PokemonType.normal,
    PokemonType.fire,
    PokemonType.water,
    PokemonType.grass,
    PokemonType.electric,
    PokemonType.ice,
    PokemonType.fighting,
    PokemonType.poison,
    PokemonType.ground,
    PokemonType.flying,
    PokemonType.psychic,
    PokemonType.bug,
    PokemonType.rock,
    PokemonType.ghost,
    PokemonType.dragon,
    PokemonType.dark,
    PokemonType.steel,
    PokemonType.fairy,
  ];

  static const double superEffective = 2;
  static const double notVeryEffective = 0.5;
  static const double immune = 0;
  static const double neutral = 1;
  static const double doubleWeak = 4;
  static const double doubleResistant = 0.25;

  static const Map<PokemonType, Map<PokemonType, double>> _chart = {
    PokemonType.normal: {
      PokemonType.rock: 0.5,
      PokemonType.ghost: 0,
      PokemonType.steel: 0.5,
    },
    PokemonType.fire: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.grass: 2,
      PokemonType.ice: 2,
      PokemonType.bug: 2,
      PokemonType.rock: 0.5,
      PokemonType.dragon: 0.5,
      PokemonType.steel: 2,
    },
    PokemonType.water: {
      PokemonType.fire: 2,
      PokemonType.water: 0.5,
      PokemonType.grass: 0.5,
      PokemonType.ground: 2,
      PokemonType.rock: 2,
      PokemonType.dragon: 0.5,
    },
    PokemonType.electric: {
      PokemonType.water: 2,
      PokemonType.electric: 0.5,
      PokemonType.grass: 0.5,
      PokemonType.ground: 0,
      PokemonType.flying: 2,
      PokemonType.dragon: 0.5,
    },
    PokemonType.grass: {
      PokemonType.fire: 0.5,
      PokemonType.water: 2,
      PokemonType.grass: 0.5,
      PokemonType.poison: 0.5,
      PokemonType.ground: 2,
      PokemonType.flying: 0.5,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.dragon: 0.5,
      PokemonType.steel: 0.5,
    },
    PokemonType.ice: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.grass: 2,
      PokemonType.ice: 0.5,
      PokemonType.ground: 2,
      PokemonType.flying: 2,
      PokemonType.dragon: 2,
      PokemonType.steel: 0.5,
    },
    PokemonType.fighting: {
      PokemonType.normal: 2,
      PokemonType.ice: 2,
      PokemonType.poison: 0.5,
      PokemonType.flying: 0.5,
      PokemonType.psychic: 0.5,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.ghost: 0,
      PokemonType.dark: 2,
      PokemonType.steel: 2,
      PokemonType.fairy: 0.5,
    },
    PokemonType.poison: {
      PokemonType.grass: 2,
      PokemonType.poison: 0.5,
      PokemonType.ground: 0.5,
      PokemonType.rock: 0.5,
      PokemonType.ghost: 0.5,
      PokemonType.steel: 0,
      PokemonType.fairy: 2,
    },
    PokemonType.ground: {
      PokemonType.fire: 2,
      PokemonType.electric: 2,
      PokemonType.grass: 0.5,
      PokemonType.poison: 2,
      PokemonType.flying: 0,
      PokemonType.bug: 0.5,
      PokemonType.rock: 2,
      PokemonType.steel: 2,
    },
    PokemonType.flying: {
      PokemonType.electric: 0.5,
      PokemonType.grass: 2,
      PokemonType.fighting: 2,
      PokemonType.bug: 2,
      PokemonType.rock: 0.5,
      PokemonType.steel: 0.5,
    },
    PokemonType.psychic: {
      PokemonType.fighting: 2,
      PokemonType.poison: 2,
      PokemonType.psychic: 0.5,
      PokemonType.dark: 0,
      PokemonType.steel: 0.5,
    },
    PokemonType.bug: {
      PokemonType.fire: 0.5,
      PokemonType.grass: 2,
      PokemonType.fighting: 0.5,
      PokemonType.poison: 0.5,
      PokemonType.flying: 0.5,
      PokemonType.psychic: 2,
      PokemonType.ghost: 0.5,
      PokemonType.dark: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 0.5,
    },
    PokemonType.rock: {
      PokemonType.fire: 2,
      PokemonType.ice: 2,
      PokemonType.fighting: 0.5,
      PokemonType.ground: 0.5,
      PokemonType.flying: 2,
      PokemonType.bug: 2,
      PokemonType.steel: 0.5,
    },
    PokemonType.ghost: {
      PokemonType.normal: 0,
      PokemonType.psychic: 2,
      PokemonType.ghost: 2,
      PokemonType.dark: 0.5,
    },
    PokemonType.dragon: {
      PokemonType.dragon: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 0,
    },
    PokemonType.dark: {
      PokemonType.fighting: 0.5,
      PokemonType.psychic: 2,
      PokemonType.ghost: 2,
      PokemonType.dark: 0.5,
      PokemonType.fairy: 0.5,
    },
    PokemonType.steel: {
      PokemonType.fire: 0.5,
      PokemonType.water: 0.5,
      PokemonType.electric: 0.5,
      PokemonType.ice: 2,
      PokemonType.rock: 2,
      PokemonType.steel: 0.5,
      PokemonType.fairy: 2,
    },
    PokemonType.fairy: {
      PokemonType.fire: 0.5,
      PokemonType.fighting: 2,
      PokemonType.poison: 0.5,
      PokemonType.dragon: 2,
      PokemonType.dark: 2,
      PokemonType.steel: 0.5,
    },
  };

  /// Single-type multiplier for [attack] against [defense].
  static double effectiveness(PokemonType attack, PokemonType defense) {
    final row = _chart[attack];
    if (row == null) return neutral;
    return row[defense] ?? neutral;
  }

  /// Combined multiplier against one or two defending types.
  ///
  /// A duplicate second type counts once. Any immunity zeroes the result.
  static double dualEffectiveness(
    PokemonType attack,
    PokemonType first, [
    PokemonType? second,
  ]) {
    if (second == null || second == first) {
      return effectiveness(attack, first);
    }
    return effectiveness(attack, first) * effectiveness(attack, second);
  }

  /// Attacking multipliers for the given defending combination.
  static Map<PokemonType, double> multipliersForDefending(
    PokemonType first, [
    PokemonType? second,
  ]) {
    return {
      for (final attack in battleTypes)
        attack: dualEffectiveness(attack, first, second),
    };
  }
}

/// Defending profile grouped by multiplier.
class TypeMatchupGroups {
  const TypeMatchupGroups({
    required this.quadWeak,
    required this.weak,
    required this.resistant,
    required this.doubleResistant,
    required this.immune,
    required this.neutral,
  });

  final List<PokemonType> quadWeak;
  final List<PokemonType> weak;
  final List<PokemonType> resistant;
  final List<PokemonType> doubleResistant;
  final List<PokemonType> immune;
  final List<PokemonType> neutral;

  /// Groups [multipliers] by multiplier value.
  factory TypeMatchupGroups.fromMultipliers(
    Map<PokemonType, double> multipliers,
  ) {
    final quadWeak = <PokemonType>[];
    final weak = <PokemonType>[];
    final resistant = <PokemonType>[];
    final doubleResistant = <PokemonType>[];
    final immune = <PokemonType>[];
    final neutral = <PokemonType>[];
    multipliers.forEach((type, multiplier) {
      if (multiplier == TypeMatchupChart.doubleWeak) {
        quadWeak.add(type);
      } else if (multiplier == TypeMatchupChart.superEffective) {
        weak.add(type);
      } else if (multiplier == TypeMatchupChart.notVeryEffective) {
        resistant.add(type);
      } else if (multiplier == TypeMatchupChart.doubleResistant) {
        doubleResistant.add(type);
      } else if (multiplier == TypeMatchupChart.immune) {
        immune.add(type);
      } else {
        neutral.add(type);
      }
    });
    return TypeMatchupGroups(
      quadWeak: List.unmodifiable(quadWeak),
      weak: List.unmodifiable(weak),
      resistant: List.unmodifiable(resistant),
      doubleResistant: List.unmodifiable(doubleResistant),
      immune: List.unmodifiable(immune),
      neutral: List.unmodifiable(neutral),
    );
  }

  /// Groups the profile for one or two defending types.
  factory TypeMatchupGroups.forDefending(
    PokemonType first, [
    PokemonType? second,
  ]) {
    return TypeMatchupGroups.fromMultipliers(
      TypeMatchupChart.multipliersForDefending(first, second),
    );
  }

  bool get isEmpty =>
      quadWeak.isEmpty &&
      weak.isEmpty &&
      resistant.isEmpty &&
      doubleResistant.isEmpty &&
      immune.isEmpty;
}
