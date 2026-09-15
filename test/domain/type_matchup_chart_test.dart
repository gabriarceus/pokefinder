import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('TypeMatchupChart battle types', () {
    test('covers exactly the 18 classic types, excluding stellar', () {
      expect(TypeMatchupChart.battleTypes.length, equals(18));
      expect(TypeMatchupChart.battleTypes.toSet().length, equals(18));
      expect(
        TypeMatchupChart.battleTypes,
        isNot(contains(PokemonType.stellar)),
      );
      for (final type in PokemonType.values) {
        if (type == PokemonType.stellar) continue;
        expect(TypeMatchupChart.battleTypes, contains(type));
      }
    });
  });

  group('TypeMatchupChart single effectiveness snapshot (Gen VI onward)', () {
    // Canonical Gen VI+ chart: attack -> {2x}, {0.5x}, {0x}. Everything else
    // is 1x. Source: Bulbapedia Type chart (Generation VI onward), cross-checked
    // against the Gen 9 18-type matrix.
    const superEffective = <PokemonType, Set<PokemonType>>{
      PokemonType.normal: {},
      PokemonType.fire: {
        PokemonType.grass,
        PokemonType.ice,
        PokemonType.bug,
        PokemonType.steel,
      },
      PokemonType.water: {
        PokemonType.fire,
        PokemonType.ground,
        PokemonType.rock,
      },
      PokemonType.electric: {PokemonType.water, PokemonType.flying},
      PokemonType.grass: {
        PokemonType.water,
        PokemonType.ground,
        PokemonType.rock,
      },
      PokemonType.ice: {
        PokemonType.grass,
        PokemonType.ground,
        PokemonType.flying,
        PokemonType.dragon,
      },
      PokemonType.fighting: {
        PokemonType.normal,
        PokemonType.ice,
        PokemonType.rock,
        PokemonType.dark,
        PokemonType.steel,
      },
      PokemonType.poison: {PokemonType.grass, PokemonType.fairy},
      PokemonType.ground: {
        PokemonType.fire,
        PokemonType.electric,
        PokemonType.poison,
        PokemonType.rock,
        PokemonType.steel,
      },
      PokemonType.flying: {
        PokemonType.grass,
        PokemonType.fighting,
        PokemonType.bug,
      },
      PokemonType.psychic: {PokemonType.fighting, PokemonType.poison},
      PokemonType.bug: {
        PokemonType.grass,
        PokemonType.psychic,
        PokemonType.dark,
      },
      PokemonType.rock: {
        PokemonType.fire,
        PokemonType.ice,
        PokemonType.flying,
        PokemonType.bug,
      },
      PokemonType.ghost: {PokemonType.psychic, PokemonType.ghost},
      PokemonType.dragon: {PokemonType.dragon},
      PokemonType.dark: {PokemonType.psychic, PokemonType.ghost},
      PokemonType.steel: {PokemonType.ice, PokemonType.rock, PokemonType.fairy},
      PokemonType.fairy: {
        PokemonType.fighting,
        PokemonType.dragon,
        PokemonType.dark,
      },
    };

    const notVeryEffective = <PokemonType, Set<PokemonType>>{
      PokemonType.normal: {PokemonType.rock, PokemonType.steel},
      PokemonType.fire: {
        PokemonType.fire,
        PokemonType.water,
        PokemonType.rock,
        PokemonType.dragon,
      },
      PokemonType.water: {
        PokemonType.water,
        PokemonType.grass,
        PokemonType.dragon,
      },
      PokemonType.electric: {
        PokemonType.electric,
        PokemonType.grass,
        PokemonType.dragon,
      },
      PokemonType.grass: {
        PokemonType.fire,
        PokemonType.grass,
        PokemonType.poison,
        PokemonType.flying,
        PokemonType.bug,
        PokemonType.dragon,
        PokemonType.steel,
      },
      PokemonType.ice: {
        PokemonType.fire,
        PokemonType.water,
        PokemonType.ice,
        PokemonType.steel,
      },
      PokemonType.fighting: {
        PokemonType.poison,
        PokemonType.flying,
        PokemonType.psychic,
        PokemonType.bug,
        PokemonType.fairy,
      },
      PokemonType.poison: {
        PokemonType.poison,
        PokemonType.ground,
        PokemonType.rock,
        PokemonType.ghost,
      },
      PokemonType.ground: {PokemonType.grass, PokemonType.bug},
      PokemonType.flying: {
        PokemonType.electric,
        PokemonType.rock,
        PokemonType.steel,
      },
      PokemonType.psychic: {PokemonType.psychic, PokemonType.steel},
      PokemonType.bug: {
        PokemonType.fire,
        PokemonType.fighting,
        PokemonType.poison,
        PokemonType.flying,
        PokemonType.ghost,
        PokemonType.steel,
        PokemonType.fairy,
      },
      PokemonType.rock: {
        PokemonType.fighting,
        PokemonType.ground,
        PokemonType.steel,
      },
      PokemonType.ghost: {PokemonType.dark},
      PokemonType.dragon: {PokemonType.steel},
      PokemonType.dark: {
        PokemonType.fighting,
        PokemonType.dark,
        PokemonType.fairy,
      },
      PokemonType.steel: {
        PokemonType.fire,
        PokemonType.water,
        PokemonType.electric,
        PokemonType.steel,
      },
      PokemonType.fairy: {
        PokemonType.fire,
        PokemonType.poison,
        PokemonType.steel,
      },
    };

    const immune = <PokemonType, Set<PokemonType>>{
      PokemonType.normal: {PokemonType.ghost},
      PokemonType.fire: {},
      PokemonType.water: {},
      PokemonType.electric: {PokemonType.ground},
      PokemonType.grass: {},
      PokemonType.ice: {},
      PokemonType.fighting: {PokemonType.ghost},
      PokemonType.poison: {PokemonType.steel},
      PokemonType.ground: {PokemonType.flying},
      PokemonType.flying: {},
      PokemonType.psychic: {PokemonType.dark},
      PokemonType.bug: {},
      PokemonType.rock: {},
      PokemonType.ghost: {PokemonType.normal},
      PokemonType.dragon: {PokemonType.fairy},
      PokemonType.dark: {},
      PokemonType.steel: {},
      PokemonType.fairy: {},
    };

    test('all 324 pairs resolve to 0, 0.5, 1, or 2', () {
      for (final attack in TypeMatchupChart.battleTypes) {
        for (final defense in TypeMatchupChart.battleTypes) {
          final value = TypeMatchupChart.effectiveness(attack, defense);
          expect(
            [0.0, 0.5, 1.0, 2.0],
            contains(value),
            reason: '$attack vs $defense = $value',
          );
        }
      }
    });

    test('full chart matches canonical multipliers', () {
      for (final attack in TypeMatchupChart.battleTypes) {
        for (final defense in TypeMatchupChart.battleTypes) {
          final expected = immune[attack]!.contains(defense)
              ? 0.0
              : superEffective[attack]!.contains(defense)
              ? 2.0
              : notVeryEffective[attack]!.contains(defense)
              ? 0.5
              : 1.0;
          expect(
            TypeMatchupChart.effectiveness(attack, defense),
            equals(expected),
            reason: '$attack vs $defense',
          );
        }
      }
    });

    test('exactly eight immunities exist', () {
      var count = 0;
      for (final attack in TypeMatchupChart.battleTypes) {
        for (final defense in TypeMatchupChart.battleTypes) {
          if (TypeMatchupChart.effectiveness(attack, defense) == 0) count++;
        }
      }
      expect(count, equals(8));
    });

    test('stellar falls back to neutral (out of chart scope)', () {
      expect(
        TypeMatchupChart.effectiveness(PokemonType.stellar, PokemonType.fire),
        equals(1),
      );
      expect(
        TypeMatchupChart.effectiveness(PokemonType.fire, PokemonType.stellar),
        equals(1),
      );
    });
  });

  group('TypeMatchupChart dual effectiveness', () {
    test('single defending type equals single effectiveness', () {
      expect(
        TypeMatchupChart.dualEffectiveness(PokemonType.water, PokemonType.fire),
        equals(2),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.water,
          PokemonType.fire,
          null,
        ),
        equals(2),
      );
    });

    test('duplicate second type counts once', () {
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.rock,
          PokemonType.fire,
          PokemonType.fire,
        ),
        equals(
          TypeMatchupChart.effectiveness(PokemonType.rock, PokemonType.fire),
        ),
      );
    });

    test('double weakness multiplies to 4x', () {
      // Charizard: Fire/Flying takes 4x from Rock.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.rock,
          PokemonType.fire,
          PokemonType.flying,
        ),
        equals(4),
      );
      // Rayquaza-style: Dragon/Flying takes 4x from Ice.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.ice,
          PokemonType.dragon,
          PokemonType.flying,
        ),
        equals(4),
      );
    });

    test('double resistance multiplies to 0.25x', () {
      // Bug vs Fighting/Poison: 0.5 * 0.5.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.bug,
          PokemonType.fighting,
          PokemonType.poison,
        ),
        equals(0.25),
      );
      // Fire vs Water/Dragon: 0.5 * 0.5.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.fire,
          PokemonType.water,
          PokemonType.dragon,
        ),
        equals(0.25),
      );
    });

    test('immunity overrides any other multiplier', () {
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.electric,
          PokemonType.ground,
          PokemonType.flying,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.ground,
          PokemonType.flying,
          PokemonType.grass,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.ghost,
          PokemonType.normal,
          PokemonType.ghost,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.dragon,
          PokemonType.fairy,
          PokemonType.dragon,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.psychic,
          PokemonType.dark,
          PokemonType.poison,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.poison,
          PokemonType.steel,
          PokemonType.fairy,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.fighting,
          PokemonType.ghost,
          PokemonType.dark,
        ),
        equals(0),
      );
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.normal,
          PokemonType.ghost,
          PokemonType.steel,
        ),
        equals(0),
      );
    });

    test('weakness plus resistance cancels to neutral', () {
      // Fire vs Grass/Water: 2 * 0.5.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.fire,
          PokemonType.grass,
          PokemonType.water,
        ),
        equals(1),
      );
      // Water vs Water/Ground: 0.5 * 2.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.water,
          PokemonType.water,
          PokemonType.ground,
        ),
        equals(1),
      );
    });

    test('multipliersForDefending covers all 18 attacking types', () {
      final single = TypeMatchupChart.multipliersForDefending(PokemonType.fire);
      expect(single.length, equals(18));
      expect(single[PokemonType.water], equals(2));
      expect(single[PokemonType.grass], equals(0.5));
      expect(single[PokemonType.electric], equals(1));

      final dual = TypeMatchupChart.multipliersForDefending(
        PokemonType.fire,
        PokemonType.flying,
      );
      expect(dual.length, equals(18));
      expect(dual[PokemonType.rock], equals(4));
      expect(dual[PokemonType.ground], equals(0));
    });
  });

  group('TypeMatchupGroups', () {
    test('groups single defending type by multiplier', () {
      final groups = TypeMatchupGroups.forDefending(PokemonType.fire);
      expect(groups.quadWeak, isEmpty);
      expect(groups.weak, containsAll([PokemonType.water]));
      expect(groups.weak, containsAll([PokemonType.ground, PokemonType.rock]));
      expect(groups.resistant, contains(PokemonType.grass));
      expect(groups.immune, isEmpty);
      expect(
        groups.weak.length +
            groups.quadWeak.length +
            groups.resistant.length +
            groups.doubleResistant.length +
            groups.immune.length +
            groups.neutral.length,
        equals(18),
      );
    });

    test('groups dual defending type with 4x, 0.25x, and immunity', () {
      final groups = TypeMatchupGroups.forDefending(
        PokemonType.fire,
        PokemonType.flying,
      );
      expect(groups.quadWeak, contains(PokemonType.rock));
      expect(groups.immune, contains(PokemonType.ground));
      // Grass vs Fire/Flying: 0.5 * 0.5 = 0.25 double resistance.
      expect(
        TypeMatchupChart.dualEffectiveness(
          PokemonType.grass,
          PokemonType.fire,
          PokemonType.flying,
        ),
        equals(0.25),
      );
      expect(groups.doubleResistant, contains(PokemonType.grass));
    });

    test('fromMultipliers routes every multiplier bucket', () {
      final groups = TypeMatchupGroups.fromMultipliers({
        PokemonType.fire: 4,
        PokemonType.water: 2,
        PokemonType.grass: 0.5,
        PokemonType.electric: 0.25,
        PokemonType.ground: 0,
        PokemonType.normal: 1,
      });
      expect(groups.quadWeak, equals([PokemonType.fire]));
      expect(groups.weak, equals([PokemonType.water]));
      expect(groups.resistant, equals([PokemonType.grass]));
      expect(groups.doubleResistant, equals([PokemonType.electric]));
      expect(groups.immune, equals([PokemonType.ground]));
      expect(groups.neutral, equals([PokemonType.normal]));
    });
  });
}
