import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_tab_scroll_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/measurement_formatter.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';

/// Width of the base, min and max value columns.
const _kValueColumnWidth = 40.0;

/// Width of the stat name column.
const _kLabelColumnWidth = 72.0;

/// Stats tab of the detail page: base, minimum and maximum of each stat.
class DetailStatsTab extends StatelessWidget {
  const DetailStatsTab({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    if (pokemon.stats.length < StatKind.values.length) {
      return Center(child: Text(t.statsNotAvailable));
    }
    final locale = Localizations.localeOf(context).languageCode;
    final total = pokemon.stats.reduce((a, b) => a + b);

    return DetailTabScrollView(
      storageKey: 'detail_stats',
      slivers: [
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact =
                  constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(t.baseStats),
                  if (!isCompact) ...[
                    _StatValuesRow(
                      label: '',
                      values: [t.statsBase, t.statsMin, t.statsMax],
                      isHeader: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                  for (final kind in StatKind.values) ...[
                    if (isCompact)
                      CompactStatRow(
                        kind: kind,
                        value: pokemon.stats[kind.index],
                        locale: locale,
                      )
                    else
                      _StatRow(
                        kind: kind,
                        value: pokemon.stats[kind.index],
                        locale: locale,
                      ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(),
                  if (isCompact)
                    Text(
                      '${t.compareTotal}: ${MeasurementFormatter.formatInteger(total, locale: locale)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    _StatValuesRow(
                      label: t.compareTotal,
                      // Empty min and max keep the total under the base column.
                      values: [
                        MeasurementFormatter.formatInteger(
                          total,
                          locale: locale,
                        ),
                        '',
                        '',
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A stat name, a bar and the base, min and max values.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.kind,
    required this.value,
    required this.locale,
  });

  final StatKind kind;
  final int value;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = statKindLabel(context, kind);
    String format(int number) =>
        MeasurementFormatter.formatInteger(number, locale: locale);
    final base = format(value);
    final min = format(StatCalculator.calculateMinStat(kind, value));
    final max = format(StatCalculator.calculateMaxStat(kind, value));

    return Semantics(
      label: '$label: $base, min $min, max $max',
      excludeSemantics: true,
      child: _StatValuesRow(
        label: label,
        bar: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value / 255.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, progress, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              color: statBarColor(value),
              minHeight: 8,
            ),
          ),
        ),
        values: [base, min, max],
      ),
    );
  }
}

/// A label column, an optional [bar] and right-aligned value columns.
class _StatValuesRow extends StatelessWidget {
  const _StatValuesRow({
    required this.label,
    required this.values,
    this.bar,
    this.isHeader = false,
  });

  final String label;
  final Widget? bar;
  final List<String> values;

  /// Draws the values as muted column titles.
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final valueStyle = isHeader
        ? theme.textTheme.labelSmall?.copyWith(color: muted)
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return Row(
      children: [
        SizedBox(
          width: _kLabelColumnWidth,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: bar ?? const SizedBox.shrink()),
        for (final value in values) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: _kValueColumnWidth,
            child: Text(value, textAlign: TextAlign.right, style: valueStyle),
          ),
        ],
      ],
    );
  }
}
