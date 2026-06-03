import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';

void main() {
  group('StatCalculator', () {
    test('HP uses its own min/max formula', () {
      expect(StatCalculator.calculateMinStat(StatKind.hp, 45), 2 * 45 + 110);
      expect(StatCalculator.calculateMaxStat(StatKind.hp, 45), 2 * 45 + 204);
    });

    test('HP base value of 1 is the Shedinja special case', () {
      expect(StatCalculator.calculateMinStat(StatKind.hp, 1), 1);
      expect(StatCalculator.calculateMaxStat(StatKind.hp, 1), 1);
    });

    test('non-HP stats share the standard formula', () {
      const base = 49;
      final expectedMin = ((2 * base + 5) * 0.9).floor();
      final expectedMax = ((2 * base + 99) * 1.1).floor();

      for (final kind in [
        StatKind.attack,
        StatKind.defense,
        StatKind.specialAttack,
        StatKind.specialDefense,
        StatKind.speed,
      ]) {
        expect(StatCalculator.calculateMinStat(kind, base), expectedMin);
        expect(StatCalculator.calculateMaxStat(kind, base), expectedMax);
      }
    });
  });
}
