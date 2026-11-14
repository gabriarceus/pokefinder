import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_team.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';

/// Summed and averaged base stats across a team's fetched members.
///
/// Both aggregates are exposed to resolve the summed-vs-average question:
/// the detail screen shows the summed row and the average row side by side,
/// reusing the comparison stat components.
class TeamStatSummary {
  const TeamStatSummary({
    required this.sums,
    required this.averages,
    required this.totalSum,
    required this.totalAverage,
    required this.countedMembers,
  });

  /// Empty summary used when no member has usable stats.
  const TeamStatSummary.empty()
    : sums = const [0, 0, 0, 0, 0, 0],
      averages = const [0, 0, 0, 0, 0, 0],
      totalSum = 0,
      totalAverage = 0,
      countedMembers = 0;

  /// Per-[StatKind] summed base stats in [StatKind] order.
  final List<int> sums;

  /// Per-[StatKind] average base stats in [StatKind] order.
  final List<double> averages;

  /// Sum of all base stats across counted members.
  final int totalSum;

  /// Average of member totals across counted members.
  final double totalAverage;

  /// Number of members that contributed stats.
  final int countedMembers;

  bool get isEmpty => countedMembers == 0;
}

/// Pure domain helpers for the local team builder.
class TeamSummaryHelper {
  const TeamSummaryHelper._();

  /// Normalizes a member slug for identity comparison.
  static String normalizeMemberKey(String name) => name.trim().toLowerCase();

  /// Whether [name] already exists in [members] (exact slug match).
  ///
  /// Forms with distinct slugs are distinct members and never collide.
  static bool isDuplicateName(List<TeamMember> members, String name) {
    final key = normalizeMemberKey(name);
    return members.any(
      (member) => normalizeMemberKey(member.pokemon.name) == key,
    );
  }

  /// Whether [members] contains any duplicated slugs.
  static bool hasDuplicateMembers(List<TeamMember> members) {
    final seen = <String>{};
    for (final member in members) {
      if (!seen.add(member.memberKey)) return true;
    }
    return false;
  }

  /// Union of elemental types across [members] in first-seen order.
  static List<PokemonType> typeCoverage(List<TeamMember> members) {
    final seen = <PokemonType>[];
    for (final member in members) {
      for (final type in member.pokemon.types) {
        if (!seen.contains(type)) seen.add(type);
      }
    }
    return seen;
  }

  /// Union of elemental types across fetched [pokemons] in first-seen order.
  static List<PokemonType> typeCoverageOfPokemons(List<Pokemon> pokemons) {
    final seen = <PokemonType>[];
    for (final pokemon in pokemons) {
      for (final type in [pokemon.type1, pokemon.type2]) {
        if (type != null && !seen.contains(type)) seen.add(type);
      }
    }
    return seen;
  }

  /// Builds summed and averaged base stats from fetched [pokemons].
  ///
  /// Only entries with at least 6 stats contribute; the rest are skipped so
  /// a partial failure never destroys the summary.
  static TeamStatSummary buildStatSummary(List<Pokemon> pokemons) {
    final usable = pokemons.where((p) => p.stats.length >= 6).toList();
    if (usable.isEmpty) return const TeamStatSummary.empty();
    final sums = List<int>.filled(StatKind.values.length, 0);
    for (final pokemon in usable) {
      for (var i = 0; i < StatKind.values.length; i++) {
        sums[i] += pokemon.stats[i];
      }
    }
    final count = usable.length.toDouble();
    final averages = sums.map((sum) => sum / count).toList();
    final totalSum = sums.fold(0, (a, b) => a + b);
    return TeamStatSummary(
      sums: sums,
      averages: averages,
      totalSum: totalSum,
      totalAverage: totalSum / count,
      countedMembers: usable.length,
    );
  }
}
