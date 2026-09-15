import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';

/// Maximum number of Pokémon entries held for side-by-side comparison (v1).
const kComparisonMaxEntries = 2;

/// Which side leads a [ComparisonStatRow].
enum ComparisonLeader { tie, first, second }

/// Aligned base/min/max stat row for two compared Pokémon.
///
/// Base values are positional: index `i` of `Pokemon.stats` always maps to
/// `StatKind.values[i]` (HP, Attack, Defense, Sp. Atk, Sp. Def, Speed), because
/// the repository maps the API stat array by name. Min/max reuse
/// [StatCalculator] so comparison stays consistent with the detail screen.
class ComparisonStatRow {
  const ComparisonStatRow({
    required this.kind,
    required this.firstBase,
    required this.secondBase,
  });

  final StatKind kind;
  final int firstBase;
  final int secondBase;

  int get firstMin => StatCalculator.calculateMinStat(kind, firstBase);
  int get firstMax => StatCalculator.calculateMaxStat(kind, firstBase);
  int get secondMin => StatCalculator.calculateMinStat(kind, secondBase);
  int get secondMax => StatCalculator.calculateMaxStat(kind, secondBase);

  ComparisonLeader get leader {
    if (firstBase == secondBase) return ComparisonLeader.tie;
    return firstBase > secondBase
        ? ComparisonLeader.first
        : ComparisonLeader.second;
  }
}

/// Builds aligned stat rows in [StatKind] order for [first] and [second].
///
/// Returns an empty list when either Pokémon has fewer than 6 stats, letting
/// callers fall back to a "stats not available" state.
List<ComparisonStatRow> buildComparisonStatRows(Pokemon first, Pokemon second) {
  if (first.stats.length < 6 || second.stats.length < 6) {
    return const [];
  }
  final kinds = StatKind.values;
  return List<ComparisonStatRow>.generate(
    kinds.length,
    (index) => ComparisonStatRow(
      kind: kinds[index],
      firstBase: first.stats[index],
      secondBase: second.stats[index],
    ),
  );
}

/// Whether another entry can be added given [currentCount] selected entries.
bool canAddToComparison(int currentCount) =>
    currentCount < kComparisonMaxEntries;
