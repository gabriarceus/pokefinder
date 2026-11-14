import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Type coverage plus summed/average base stats for [members].
///
/// Both sections read the same fetched [Pokemon]s, so one widget owns the
/// fetch: the stored member refs carry no types unless the member was added
/// from a detail screen, and coverage can only be complete once they resolve.
class TeamSummarySection extends StatefulWidget {
  const TeamSummarySection({super.key, required this.members});

  final List<TeamMember> members;

  @override
  State<TeamSummarySection> createState() => _TeamSummarySectionState();
}

class _TeamSummarySectionState extends State<TeamSummarySection> {
  late final PokemonListCubit _cubit = createPokemonListCubit(_names);

  List<String> get _names => [
    for (final member in widget.members) member.pokemon.name,
  ];

  @override
  void didUpdateWidget(covariant TeamSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameMemberOrder(oldWidget.members, widget.members)) {
      _cubit.load(_names);
    }
  }

  static bool _sameMemberOrder(List<TeamMember> a, List<TeamMember> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reads `_cubit.state`, not the builder value: after a member change the
    // builder value lags one frame behind `widget.members`.
    return BlocBuilder<PokemonListCubit, List<PokemonLoad>>(
      bloc: _cubit,
      builder: (context, _) => _buildSummary(context, _cubit.state),
    );
  }

  Widget _buildSummary(BuildContext context, List<PokemonLoad> loads) {
    final t = context.t();
    final locale = Localizations.localeOf(context).languageCode;
    final loaded = [
      for (final load in loads)
        if (load case PokemonLoaded(:final pokemon)) pokemon,
    ];
    final failed = [for (final load in loads) load is PokemonLoadFailed];
    final isLoading = loaded.isEmpty && !failed.contains(true);
    // The stored refs are a usable answer only until the fetched members land.
    final coverage = loaded.isEmpty
        ? TeamSummaryHelper.typeCoverage(widget.members)
        : TeamSummaryHelper.typeCoverageOfPokemons(loaded);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionTitle(t.teamSummary),
            Text(
              t.teamTypeCoverage,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (coverage.isEmpty)
              Text(isLoading ? '' : t.noData)
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final type in coverage) TypeChip(type: type)],
              ),
            const Divider(height: 24),
            Text(t.baseStats, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildStats(context, t, locale, loaded, failed, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AppLocalizations t,
    String locale,
    List<Pokemon> loaded,
    List<bool> failed,
    bool isLoading,
  ) {
    if (widget.members.isEmpty) return Text(t.statsNotAvailable);
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final summary = TeamSummaryHelper.buildStatSummary(loaded);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.isEmpty)
          Text(t.statsNotAvailable)
        else ...[
          // Names the two columns, which are otherwise only implied by the
          // per-row layout.
          _TeamStatHeader(
            sumLabel: t.teamStatsSumColumn,
            statLabel: t.baseStats,
            averageLabel: t.teamStatsAverageColumn,
          ),
          for (var i = 0; i < StatKind.values.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TeamStatRow(
                kind: StatKind.values[i],
                sum: summary.sums[i],
                average: summary.averages[i],
                locale: locale,
              ),
            ),
          const Divider(height: 16),
          Text(
            '${t.teamStatsSum}: ${MeasurementFormatter.formatInteger(summary.totalSum, locale: locale)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${t.teamStatsAverage}: ${NumberFormat('0.0', locale).format(summary.totalAverage)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
        for (var i = 0; i < widget.members.length; i++)
          if (failed[i])
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.members[i].pokemon.name)),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      tooltip: t.retryButton,
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => _cubit.retry(i),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Column header naming the summed and averaged stat of every row below.
class _TeamStatHeader extends StatelessWidget {
  const _TeamStatHeader({
    required this.sumLabel,
    required this.statLabel,
    required this.averageLabel,
  });

  final String sumLabel;
  final String statLabel;
  final String averageLabel;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(sumLabel, style: style)),
          Expanded(
            child: Text(statLabel, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 56,
            child: Text(averageLabel, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// One summed/average stat row reusing the comparison stat components.
class _TeamStatRow extends StatelessWidget {
  const _TeamStatRow({
    required this.kind,
    required this.sum,
    required this.average,
    required this.locale,
  });

  final StatKind kind;
  final int sum;
  final double average;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = statKindLabel(context, kind);
    final formattedSum = MeasurementFormatter.formatInteger(
      sum,
      locale: locale,
    );
    final formattedAverage = NumberFormat('0.0', locale).format(average);
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;

    return Semantics(
      label: context.t().teamStatSumAverageSemantics(
        stat: label,
        sum: formattedSum,
        average: formattedAverage,
      ),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 56, child: Text(formattedSum, style: baseStyle)),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  formattedAverage,
                  textAlign: TextAlign.right,
                  style: baseStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (average / 255.0).clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: statBarColor(average.round()),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
