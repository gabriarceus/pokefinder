import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/empty_state_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Side-by-side comparison of up to two Pokémon.
///
/// Each side shows its own loading or failure state, so a failure on one side
/// never hides the other.
class ComparisonPage extends StatelessWidget {
  const ComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    return BlocBuilder<ComparisonCubit, ComparisonState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(t.compareTitle),
            actions: [
              if (!state.isEmpty)
                IconButton(
                  tooltip: t.compareClear,
                  icon: const Icon(Icons.clear_all_rounded),
                  onPressed: () => context.read<ComparisonCubit>().clear(),
                ),
            ],
          ),
          body: state.isEmpty
              ? EmptyStateView(
                  icon: Icons.compare_arrows_rounded,
                  title: t.compareEmptyTitle,
                  message: t.compareEmptyMessage,
                  action: FilledButton(
                    onPressed: () => context.push(AppRoutes.pokedex),
                    child: Text(t.browsePokedex),
                  ),
                )
              : _ComparisonCard(state: state),
        );
      },
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.state});

  final ComparisonState state;

  @override
  Widget build(BuildContext context) {
    final first = state.entries.first;
    final second = state.entries.length > 1 ? state.entries[1] : null;
    final firstDetail = state.detailOf(first);
    final secondDetail = second == null ? null : state.detailOf(second);

    Widget sides(Widget Function(PokemonSummary entry) side, Widget empty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: side(first)),
          const SizedBox(width: 12),
          Expanded(child: second == null ? empty : side(second)),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sides(
                (entry) => _SlotHeader(entry: entry),
                const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              sides(
                (entry) => _IdentityColumn(
                  entry: entry,
                  detail: state.detailOf(entry),
                ),
                const _EmptySlot(),
              ),
              const Divider(height: 24),
              SectionTitle(context.t().baseStats),
              switch ((firstDetail, secondDetail)) {
                (
                  ComparisonDetailLoaded(pokemon: final a),
                  ComparisonDetailLoaded(pokemon: final b),
                ) =>
                  _DualStats(first: a, second: b),
                _ => sides(
                  (entry) => switch (state.detailOf(entry)) {
                    ComparisonDetailLoaded(:final pokemon) => _SingleStats(
                      pokemon: pokemon,
                    ),
                    ComparisonDetailLoading() ||
                    ComparisonDetailFailed() => const SizedBox.shrink(),
                  },
                  const SizedBox.shrink(),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  const _SlotHeader({required this.entry});

  final PokemonSummary entry;

  Future<void> _share(BuildContext context) async {
    final link = buildPokemonCanonicalPath(entry.name);
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.t().shareLinkCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final textTheme = Theme.of(context).textTheme;
    final entryRef = entry.toIndexEntry();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entryRef.formattedId, style: textTheme.labelMedium),
              Text(
                context.translatePokemonIndexEntry(entryRef),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: t.shareLink,
          icon: const Icon(Icons.link_rounded),
          onPressed: () => _share(context),
        ),
        IconButton(
          tooltip: t.compareRemove,
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              context.read<ComparisonCubit>().removeEntry(entry.id),
        ),
      ],
    );
  }
}

/// Sprite, types and size of one side, or its loading or failure state.
class _IdentityColumn extends StatelessWidget {
  const _IdentityColumn({required this.entry, required this.detail});

  final PokemonSummary entry;
  final ComparisonDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    switch (detail) {
      case ComparisonDetailLoading():
        return const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case ComparisonDetailFailed(:final failure):
        return Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              failure.localizedMessage(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  context.read<ComparisonCubit>().loadDetails(entry),
              child: Text(t.retryButton),
            ),
          ],
        );
      case ComparisonDetailLoaded(:final pokemon):
        final locale = Localizations.localeOf(context).languageCode;
        final unitSystem = context.select<PreferencesCubit, UnitSystem>(
          (cubit) => cubit.state.unitSystem,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: SpriteBoxImage(sprite: pokemon.sprite, size: 96)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in [pokemon.type1, pokemon.type2])
                  if (type != null) TypeChip(type: type),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${t.weight}: ${MeasurementFormatter.formatWeight(pokemon.weightInKg, unitSystem, locale: locale)}',
            ),
            const SizedBox(height: 4),
            Text(
              '${t.height}: ${MeasurementFormatter.formatHeight(pokemon.heightInMeters, unitSystem, locale: locale)}',
            ),
          ],
        );
    }
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.add_circle_outline_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          context.t().compareAddSecond,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.pokedex),
          child: Text(context.t().browsePokedex),
        ),
      ],
    );
  }
}

/// Stats of a single Pokémon, with its total.
class _SingleStats extends StatelessWidget {
  const _SingleStats({required this.pokemon});

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
class _DualStats extends StatelessWidget {
  const _DualStats({required this.first, required this.second});

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
