import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/stat_calculator.dart';
import 'package:pokefinder/src/3_domain/helpers/measurement_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailStatsTab extends StatelessWidget {
  const DetailStatsTab({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    if (pokemon.stats.length < 6) {
      return Center(child: Text(context.t().statsNotAvailable));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        final isCompact =
            constraints.maxWidth < 360 || textScaler.scale(1) > 1.3;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t().baseStats,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              if (!isCompact) ...[
                Row(
                  children: [
                    const SizedBox(width: 70),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 40,
                      child: Text(
                        context.t().statsBase,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        context.t().statsMin,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        context.t().statsMax,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              _buildStatRow(
                context,
                context.t().statHp,
                StatKind.hp,
                pokemon.stats[0],
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                context.t().statAttack,
                StatKind.attack,
                pokemon.stats[1],
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                context.t().statDefense,
                StatKind.defense,
                pokemon.stats[2],
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                context.t().statSpAtk,
                StatKind.specialAttack,
                pokemon.stats[3],
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                context.t().statSpDef,
                StatKind.specialDefense,
                pokemon.stats[4],
                isCompact,
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                context,
                context.t().statSpeed,
                StatKind.speed,
                pokemon.stats[5],
                isCompact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    StatKind kind,
    int value,
    bool isCompact,
  ) {
    final statColor = statBarColor(value);
    final minVal = StatCalculator.calculateMinStat(kind, value);
    final maxVal = StatCalculator.calculateMaxStat(kind, value);

    final locale = Localizations.localeOf(context).languageCode;
    final formattedValue = MeasurementFormatter.formatInteger(
      value,
      locale: locale,
    );
    final formattedMinVal = MeasurementFormatter.formatInteger(
      minVal,
      locale: locale,
    );
    final formattedMaxVal = MeasurementFormatter.formatInteger(
      maxVal,
      locale: locale,
    );

    final progressBar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value / 255.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, val, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: val,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            color: statColor,
            minHeight: 8,
          ),
        );
      },
    );

    final semanticLabel =
        '$label: $formattedValue, min $formattedMinVal, max $formattedMaxVal';

    if (isCompact) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${context.t().statsBase}: $formattedValue | ${context.t().statsMin}: $formattedMinVal | ${context.t().statsMax}: $formattedMaxVal',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            progressBar,
          ],
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: progressBar),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              formattedValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              formattedMinVal,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              formattedMaxVal,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
