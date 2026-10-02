import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Stats of a single Pokémon, with its total.
class ComparisonSingleStats extends StatelessWidget {
  const ComparisonSingleStats({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    if (pokemon.stats.length < StatKind.values.length) {
      return Text(t.statsNotAvailable);
    }
    final locale = Localizations.localeOf(context).languageCode;
    final total = pokemon.stats.reduce((a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final kind in StatKind.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CompactStatRow(
              kind: kind,
              value: pokemon.stats[kind.index],
              locale: locale,
            ),
          ),
        const Divider(height: 16),
        Text(
          '${t.compareTotal}: ${MeasurementFormatter.formatInteger(total, locale: locale)}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Aligned `[first] <stat> [second]` rows with the leader highlighted.
class ComparisonDualStats extends StatelessWidget {
  const ComparisonDualStats({
    super.key,
    required this.first,
    required this.second,
  });

  final Pokemon first;
  final Pokemon second;

  @override
  Widget build(BuildContext context) {
    final rows = buildComparisonStatRows(first, second);
    if (rows.isEmpty) return Text(context.t().statsNotAvailable);
    final locale = Localizations.localeOf(context).languageCode;
    String format(int value) =>
        MeasurementFormatter.formatInteger(value, locale: locale);
    final t = context.t();
    final theme = Theme.of(context);
    final firstTotal = first.stats.reduce((a, b) => a + b);
    final secondTotal = second.stats.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ValuesRow(
                  label: statKindLabel(context, row.kind),
                  first: format(row.firstBase),
                  second: format(row.secondBase),
                  leader: row.leader,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t.statsMin}: ${format(row.firstMin)} | ${t.statsMax}: ${format(row.firstMax)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${t.statsMin}: ${format(row.secondMin)} | ${t.statsMax}: ${format(row.secondMax)}',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final value in [row.firstBase, row.secondBase])
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value / 255.0,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: statBarColor(value),
                        minHeight: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const Divider(height: 16),
        _ValuesRow(
          label: t.compareTotal,
          first: format(firstTotal),
          second: format(secondTotal),
          leader: firstTotal == secondTotal
              ? ComparisonLeader.tie
              : firstTotal > secondTotal
              ? ComparisonLeader.first
              : ComparisonLeader.second,
        ),
      ],
    );
  }
}

class _ValuesRow extends StatelessWidget {
  const _ValuesRow({
    required this.label,
    required this.first,
    required this.second,
    required this.leader,
  });

  final String label;
  final String first;
  final String second;
  final ComparisonLeader leader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;
    final leaderStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
    return Semantics(
      label: '$label: $first, $second',
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              first,
              style: leader == ComparisonLeader.first ? leaderStyle : baseStyle,
            ),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              second,
              textAlign: TextAlign.right,
              style: leader == ComparisonLeader.second
                  ? leaderStyle
                  : baseStyle,
            ),
          ),
        ],
      ),
    );
  }
}
