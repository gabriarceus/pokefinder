import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/stat_bar_color.dart';
import 'package:pokefinder/src/3_domain/helpers/measurement_formatter.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';

/// Localized label for a [StatKind].
String statKindLabel(BuildContext context, StatKind kind) {
  final t = context.t();
  return switch (kind) {
    StatKind.hp => t.statHp,
    StatKind.attack => t.statAttack,
    StatKind.defense => t.statDefense,
    StatKind.specialAttack => t.statSpAtk,
    StatKind.specialDefense => t.statSpDef,
    StatKind.speed => t.statSpeed,
  };
}

/// Compact single-value stat row shared by detail and comparison views.
///
/// Renders the stat [label], `Base | Min | Max` line, and an animated bar
/// colored with [statBarColor]. Min/max reuse [StatCalculator] so every
/// surface stays consistent with the detail screen.
class CompactStatRow extends StatelessWidget {
  const CompactStatRow({
    super.key,
    required this.kind,
    required this.value,
    required this.locale,
    this.textColor,
  });

  final StatKind kind;
  final int value;
  final String locale;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final baseColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final minVal = StatCalculator.calculateMinStat(kind, value);
    final maxVal = StatCalculator.calculateMaxStat(kind, value);
    final formattedValue = MeasurementFormatter.formatInteger(
      value,
      locale: locale,
    );
    final formattedMin = MeasurementFormatter.formatInteger(
      minVal,
      locale: locale,
    );
    final formattedMax = MeasurementFormatter.formatInteger(
      maxVal,
      locale: locale,
    );
    final label = statKindLabel(context, kind);

    return Semantics(
      label: '$label: $formattedValue, min $formattedMin, max $formattedMax',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: baseColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${context.t().statsBase}: $formattedValue | ${context.t().statsMin}: $formattedMin | ${context.t().statsMax}: $formattedMax',
            style: TextStyle(
              fontSize: 12,
              color: baseColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value / 255.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, val, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: val,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  color: statBarColor(value),
                  minHeight: 8,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
