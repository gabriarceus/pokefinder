import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

void main() {
  group('buildComparisonStatRows', () {
    test('aligns rows in StatKind order with correct base values', () {
      final first = buildPokemon();
      final second = buildPokemon(
        id: 4,
        name: 'charmander',
        type1: PokemonType.fire,
        type2: null,
      );

      final rows = buildComparisonStatRows(first, second);

      expect(rows.length, equals(StatKind.values.length));
      expect(rows.map((row) => row.kind).toList(), equals(StatKind.values));
      expect(rows.first.kind, equals(StatKind.hp));
      expect(rows.first.firstBase, equals(45));
      expect(rows.first.secondBase, equals(45));
      expect(rows[1].kind, equals(StatKind.attack));
      expect(rows[1].firstBase, equals(49));
      expect(rows.last.kind, equals(StatKind.speed));
      expect(rows.last.firstBase, equals(45));
    });

    test('min/max reuse StatCalculator for every row', () {
      final first = buildPokemon();
      final second = buildPokemon(id: 25, name: 'pikachu');

      final rows = buildComparisonStatRows(first, second);

      for (final row in rows) {
        expect(
          row.firstMin,
          equals(StatCalculator.calculateMinStat(row.kind, row.firstBase)),
        );
        expect(
          row.firstMax,
          equals(StatCalculator.calculateMaxStat(row.kind, row.firstBase)),
        );
        expect(
          row.secondMin,
          equals(StatCalculator.calculateMinStat(row.kind, row.secondBase)),
        );
        expect(
          row.secondMax,
          equals(StatCalculator.calculateMaxStat(row.kind, row.secondBase)),
        );
      }
    });

    test('reports the leading side per row', () {
      final first = buildPokemon();
      final strong = buildPokemon(
        id: 150,
        name: 'mewtwo',
        stats: const [106, 110, 90, 154, 90, 130],
      );
      final weak = buildPokemon(
        id: 10,
        name: 'caterpie',
        stats: const [45, 30, 35, 20, 20, 45],
      );

      final tied = buildComparisonStatRows(first, buildPokemon());
      expect(
        tied.map((row) => row.leader),
        everyElement(equals(ComparisonLeader.tie)),
      );

      final losing = buildComparisonStatRows(weak, strong);
      expect(
        losing.map((row) => row.leader),
        everyElement(equals(ComparisonLeader.second)),
      );

      final winning = buildComparisonStatRows(strong, weak);
      expect(
        winning.map((row) => row.leader),
        everyElement(equals(ComparisonLeader.first)),
      );
    });

    test('returns empty when either side has fewer than 6 stats', () {
      final full = buildPokemon();
      final short = buildPokemon(id: 2, name: 'ivysaur', stats: [45, 60, 65]);

      expect(buildComparisonStatRows(full, short), isEmpty);
      expect(buildComparisonStatRows(short, full), isEmpty);
    });
  });

  group('canAddToComparison', () {
    test('allows entries below the cap and rejects at the cap', () {
      expect(canAddToComparison(0), isTrue);
      expect(canAddToComparison(1), isTrue);
      expect(canAddToComparison(kComparisonMaxEntries), isFalse);
      expect(canAddToComparison(kComparisonMaxEntries + 1), isFalse);
    });

    test('caps the comparison at two entries', () {
      expect(kComparisonMaxEntries, equals(2));
    });
  });

  group('unit conversion reuse', () {
    test('formats comparison weight in both unit systems', () {
      expect(
        MeasurementFormatter.formatWeight(6.9, UnitSystem.metric, locale: 'en'),
        equals('6.9 kg'),
      );
      expect(
        MeasurementFormatter.formatWeight(
          6.9,
          UnitSystem.imperial,
          locale: 'en',
        ),
        equals('15.2 lbs'),
      );
    });

    test('formats comparison height in both unit systems', () {
      expect(
        MeasurementFormatter.formatHeight(0.7, UnitSystem.metric, locale: 'en'),
        equals('0.7 m'),
      );
      expect(
        MeasurementFormatter.formatHeight(
          0.7,
          UnitSystem.imperial,
          locale: 'en',
        ),
        equals('2\' 04"'),
      );
    });
  });
}
