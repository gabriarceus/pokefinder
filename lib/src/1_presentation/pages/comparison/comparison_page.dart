import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Side-by-side comparison of up to two Pokémon.
///
/// Each entry fetches its details through its own [PokemonBloc], so a failure
/// on one side renders inline retry without destroying the valid side.
/// Stats reuse [StatCalculator], [statBarColor], [TypeChip],
/// [MeasurementFormatter], and [buildComparisonStatRows] for consistency
/// with the detail screen.
class ComparisonPage extends StatelessWidget {
  const ComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComparisonCubit, ComparisonState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.t().compareTitle),
            actions: [
              if (state.entries.isNotEmpty)
                IconButton(
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(48, 48)),
                  ),
                  tooltip: context.t().compareClear,
                  icon: const Icon(Icons.clear_all_rounded),
                  onPressed: () => context.read<ComparisonCubit>().clear(),
                ),
            ],
          ),
          body: state.entries.isEmpty
              ? const _ComparisonEmptyView()
              : _ComparisonBody(entries: state.entries),
        );
      },
    );
  }
}

class _ComparisonBody extends StatelessWidget {
  const _ComparisonBody({required this.entries});

  final List<PokemonIndexEntry> entries;

  Widget _slot(PokemonIndexEntry entry) {
    return PokemonBlocProvider(
      key: ValueKey('compare-${entry.id}'),
      pokemonName: entry.name,
      child: ComparisonSlotBody(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entries.length > 1) {
      // Two entries share one card with an aligned comparison table, so rows
      // stay side by side even on narrow phones.
      return _DualComparisonView(
        key: ValueKey('compare-dual-${entries[0].id}-${entries[1].id}'),
        first: entries[0],
        second: entries[1],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        const second = _ComparisonEmptySlot();
        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _slot(entries[0])),
                const SizedBox(width: 12),
                const Expanded(child: second),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [_slot(entries[0]), const SizedBox(height: 12), second],
          ),
        );
      },
    );
  }
}

/// Two-entry comparison driven by two nested [PokemonBloc] instances.
///
/// The outer provider owns the first entry, the inner provider owns the
/// second; both blocs are captured explicitly so the shared table can read
/// them without same-type shadowing.
class _DualComparisonView extends StatelessWidget {
  const _DualComparisonView({
    super.key,
    required this.first,
    required this.second,
  });

  final PokemonIndexEntry first;
  final PokemonIndexEntry second;

  @override
  Widget build(BuildContext context) {
    return PokemonBlocProvider(
      key: ValueKey('compare-first-${first.id}'),
      pokemonName: first.name,
      child: Builder(
        builder: (outerContext) {
          final firstBloc = outerContext.read<PokemonBloc>();
          return PokemonBlocProvider(
            key: ValueKey('compare-second-${second.id}'),
            pokemonName: second.name,
            child: Builder(
              builder: (innerContext) {
                final secondBloc = innerContext.read<PokemonBloc>();
                return _DualComparisonContent(
                  firstBloc: firstBloc,
                  secondBloc: secondBloc,
                  firstEntry: first,
                  secondEntry: second,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DualComparisonContent extends StatelessWidget {
  const _DualComparisonContent({
    required this.firstBloc,
    required this.secondBloc,
    required this.firstEntry,
    required this.secondEntry,
  });

  final PokemonBloc firstBloc;
  final PokemonBloc secondBloc;
  final PokemonIndexEntry firstEntry;
  final PokemonIndexEntry secondEntry;

  UnitSystem _unitSystem(BuildContext context) {
    try {
      return context.watch<PreferencesCubit>().state.unitSystem;
    } catch (_) {
      return UnitSystem.metric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final unitSystem = _unitSystem(context);
    final firstName = context.translatePokemonIndexEntry(firstEntry);
    final secondName = context.translatePokemonIndexEntry(secondEntry);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SlotHeader(
                      entry: firstEntry,
                      pokemonName: firstName,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SlotHeader(
                      entry: secondEntry,
                      pokemonName: secondName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DualIdentityColumn(
                      bloc: firstBloc,
                      entry: firstEntry,
                      displayName: firstName,
                      unitSystem: unitSystem,
                      locale: locale,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DualIdentityColumn(
                      bloc: secondBloc,
                      entry: secondEntry,
                      displayName: secondName,
                      unitSystem: unitSystem,
                      locale: locale,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                context.t().baseStats,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _DualStatsTable(
                firstBloc: firstBloc,
                secondBloc: secondBloc,
                firstEntry: firstEntry,
                secondEntry: secondEntry,
                firstName: firstName,
                secondName: secondName,
                locale: locale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sprite, types, and dimensions for one side of the dual comparison.
class _DualIdentityColumn extends StatelessWidget {
  const _DualIdentityColumn({
    required this.bloc,
    required this.entry,
    required this.displayName,
    required this.unitSystem,
    required this.locale,
  });

  final PokemonBloc bloc;
  final PokemonIndexEntry entry;
  final String displayName;
  final UnitSystem unitSystem;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonBloc, PokemonBlocState>(
      bloc: bloc,
      builder: (slotContext, state) {
        return state.map(
          onInitial: (_) => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          onLoading: (_) => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          onFailure: (failure) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Theme.of(slotContext).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                failure.failure.localizedMessage(slotContext),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => bloc.add(FetchPokemonEvent(entry.name)),
                child: Text(slotContext.t().retryButton),
              ),
            ],
          ),
          onSuccess: (success) {
            final pokemon = success.pokemon;
            return Semantics(
              label: '$displayName, ${entry.formattedId}',
              excludeSemantics: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: pokemon.sprite.isNotEmpty
                        ? Image.network(
                            pokemon.sprite,
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.catching_pokemon, size: 72),
                          )
                        : const Icon(Icons.catching_pokemon, size: 72),
                  ),
                  const SizedBox(height: 8),
                  if (pokemon.type1 != null || pokemon.type2 != null)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (pokemon.type1 != null)
                          TypeChip(
                            type: pokemon.type1!,
                            imageUrl: pokemon.typeImage1.isNotEmpty
                                ? pokemon.typeImage1
                                : null,
                          ),
                        if (pokemon.type2 != null)
                          TypeChip(
                            type: pokemon.type2!,
                            imageUrl: pokemon.typeImage2.isNotEmpty
                                ? pokemon.typeImage2
                                : null,
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${slotContext.t().weight}: ${MeasurementFormatter.formatWeight(pokemon.weightInKg, unitSystem, locale: locale)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${slotContext.t().height}: ${MeasurementFormatter.formatHeight(pokemon.heightInMeters, unitSystem, locale: locale)}',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Aligned stat table for both sides, driven by [buildComparisonStatRows].
///
/// When both sides succeed with 6 stats, rows render as
/// `[first] <stat> [second]` with leader highlighting. Otherwise each side
/// falls back to its own loading/failure/single-column rendering so a
/// failure never destroys the valid side.
class _DualStatsTable extends StatelessWidget {
  const _DualStatsTable({
    required this.firstBloc,
    required this.secondBloc,
    required this.firstEntry,
    required this.secondEntry,
    required this.firstName,
    required this.secondName,
    required this.locale,
  });

  final PokemonBloc firstBloc;
  final PokemonBloc secondBloc;
  final PokemonIndexEntry firstEntry;
  final PokemonIndexEntry secondEntry;
  final String firstName;
  final String secondName;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonBloc, PokemonBlocState>(
      bloc: firstBloc,
      builder: (context, firstState) {
        return BlocBuilder<PokemonBloc, PokemonBlocState>(
          bloc: secondBloc,
          builder: (context, secondState) {
            final firstPokemon = firstState is PokemonBlocSuccess
                ? firstState.pokemon
                : null;
            final secondPokemon = secondState is PokemonBlocSuccess
                ? secondState.pokemon
                : null;
            if (firstPokemon != null && secondPokemon != null) {
              final rows = buildComparisonStatRows(firstPokemon, secondPokemon);
              if (rows.isNotEmpty) {
                final firstTotal = firstPokemon.stats.reduce((a, b) => a + b);
                final secondTotal = secondPokemon.stats.reduce((a, b) => a + b);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < rows.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == rows.length - 1 ? 0 : 10,
                        ),
                        child: _AlignedStatRow(
                          row: rows[i],
                          firstName: firstName,
                          secondName: secondName,
                          locale: locale,
                        ),
                      ),
                    const Divider(height: 16),
                    _DualTotalRow(
                      firstTotal: firstTotal,
                      secondTotal: secondTotal,
                      firstName: firstName,
                      secondName: secondName,
                      locale: locale,
                    ),
                  ],
                );
              }
              if (firstPokemon.stats.length < 6 ||
                  secondPokemon.stats.length < 6) {
                return Text(context.t().statsNotAvailable);
              }
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SingleSideStatsFallback(
                    state: firstState,
                    bloc: firstBloc,
                    entry: firstEntry,
                    locale: locale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SingleSideStatsFallback(
                    state: secondState,
                    bloc: secondBloc,
                    entry: secondEntry,
                    locale: locale,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Per-side stats rendering used while the other side is loading or failed.
class _SingleSideStatsFallback extends StatelessWidget {
  const _SingleSideStatsFallback({
    required this.state,
    required this.bloc,
    required this.entry,
    required this.locale,
  });

  final PokemonBlocState state;
  final PokemonBloc bloc;
  final PokemonIndexEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return state.map(
      onInitial: (_) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      onLoading: (_) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      onFailure: (failure) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            failure.failure.localizedMessage(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => bloc.add(FetchPokemonEvent(entry.name)),
            child: Text(context.t().retryButton),
          ),
        ],
      ),
      onSuccess: (success) {
        final pokemon = success.pokemon;
        if (pokemon.stats.length < 6) {
          return Text(context.t().statsNotAvailable);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < StatKind.values.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CompactStatRow(
                  kind: StatKind.values[i],
                  value: pokemon.stats[i],
                  locale: locale,
                ),
              ),
            const Divider(height: 16),
            Text(
              '${context.t().compareTotal}: ${MeasurementFormatter.formatInteger(pokemon.stats.reduce((a, b) => a + b), locale: locale)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}

/// One aligned stat row: `[first] <stat> [second]` with leader emphasis.
class _AlignedStatRow extends StatelessWidget {
  const _AlignedStatRow({
    required this.row,
    required this.firstName,
    required this.secondName,
    required this.locale,
  });

  final ComparisonStatRow row;
  final String firstName;
  final String secondName;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = statKindLabel(context, row.kind);
    final firstBase = MeasurementFormatter.formatInteger(
      row.firstBase,
      locale: locale,
    );
    final secondBase = MeasurementFormatter.formatInteger(
      row.secondBase,
      locale: locale,
    );
    final firstMin = MeasurementFormatter.formatInteger(
      row.firstMin,
      locale: locale,
    );
    final firstMax = MeasurementFormatter.formatInteger(
      row.firstMax,
      locale: locale,
    );
    final secondMin = MeasurementFormatter.formatInteger(
      row.secondMin,
      locale: locale,
    );
    final secondMax = MeasurementFormatter.formatInteger(
      row.secondMax,
      locale: locale,
    );
    final theme = Theme.of(context);
    final leaderColor = theme.colorScheme.primary;
    final baseStyle = theme.textTheme.bodyMedium;
    final leaderStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: leaderColor,
    );

    return Semantics(
      label: '$label: $firstName $firstBase, $secondName $secondBase',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  firstBase,
                  textAlign: TextAlign.left,
                  style: row.leader == ComparisonLeader.first
                      ? leaderStyle
                      : baseStyle,
                ),
              ),
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
                  secondBase,
                  textAlign: TextAlign.right,
                  style: row.leader == ComparisonLeader.second
                      ? leaderStyle
                      : baseStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t().statsMin}: $firstMin | ${context.t().statsMax}: $firstMax',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '${context.t().statsMin}: $secondMin | ${context.t().statsMax}: $secondMax',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: row.firstBase / 255.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: statBarColor(row.firstBase),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: row.secondBase / 255.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: statBarColor(row.secondBase),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DualTotalRow extends StatelessWidget {
  const _DualTotalRow({
    required this.firstTotal,
    required this.secondTotal,
    required this.firstName,
    required this.secondName,
    required this.locale,
  });

  final int firstTotal;
  final int secondTotal;
  final String firstName;
  final String secondName;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final first = MeasurementFormatter.formatInteger(
      firstTotal,
      locale: locale,
    );
    final second = MeasurementFormatter.formatInteger(
      secondTotal,
      locale: locale,
    );
    ComparisonLeader leader = ComparisonLeader.tie;
    if (firstTotal > secondTotal) {
      leader = ComparisonLeader.first;
    } else if (secondTotal > firstTotal) {
      leader = ComparisonLeader.second;
    }
    final theme = Theme.of(context);
    final baseStyle = const TextStyle(fontWeight: FontWeight.bold);
    final leaderStyle = baseStyle.copyWith(color: theme.colorScheme.primary);

    return Semantics(
      label:
          '${context.t().compareTotal}: $firstName $first, $secondName $second',
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
              context.t().compareTotal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
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

/// Single compared entry column driven by its own [PokemonBloc].
///
/// Public for testing: pump with a [BlocProvider.value] holding a seeded
/// [PokemonBloc] to cover loading, failure/retry, and success states.
class ComparisonSlotBody extends StatelessWidget {
  const ComparisonSlotBody({super.key, required this.entry});

  final PokemonIndexEntry entry;

  @override
  Widget build(BuildContext context) {
    return PokemonBlocBuilder(
      onInitial: (_, _) => _slotCard(
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      onLoading: (_, _) => _slotCard(
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      onFailure: (slotContext, failure) => _slotCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SlotHeader(entry: entry, pokemonName: entry.name),
            const SizedBox(height: 12),
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Theme.of(slotContext).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              failure.failure.localizedMessage(slotContext),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => slotContext.read<PokemonBloc>().add(
                FetchPokemonEvent(entry.name),
              ),
              child: Text(slotContext.t().retryButton),
            ),
          ],
        ),
      ),
      onSuccess: (_, success) =>
          _ComparisonSlotSuccess(entry: entry, pokemon: success.pokemon),
    );
  }
}

Widget _slotCard({required Widget child}) {
  return Card(
    child: Padding(padding: const EdgeInsets.all(12), child: child),
  );
}

class _ComparisonSlotSuccess extends StatelessWidget {
  const _ComparisonSlotSuccess({required this.entry, required this.pokemon});

  final PokemonIndexEntry entry;
  final Pokemon pokemon;

  UnitSystem _unitSystem(BuildContext context) {
    try {
      return context.watch<PreferencesCubit>().state.unitSystem;
    } catch (_) {
      return UnitSystem.metric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final unitSystem = _unitSystem(context);
    final displayName = context.translatePokemonIndexEntry(entry);
    final semanticLabel = '$displayName, ${entry.formattedId}';

    return _slotCard(
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SlotHeader(entry: entry, pokemonName: displayName),
            const SizedBox(height: 8),
            Center(
              child: pokemon.sprite.isNotEmpty
                  ? Image.network(
                      pokemon.sprite,
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.catching_pokemon, size: 72),
                    )
                  : const Icon(Icons.catching_pokemon, size: 72),
            ),
            const SizedBox(height: 8),
            if (pokemon.type1 != null || pokemon.type2 != null)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (pokemon.type1 != null)
                    TypeChip(
                      type: pokemon.type1!,
                      imageUrl: pokemon.typeImage1.isNotEmpty
                          ? pokemon.typeImage1
                          : null,
                    ),
                  if (pokemon.type2 != null)
                    TypeChip(
                      type: pokemon.type2!,
                      imageUrl: pokemon.typeImage2.isNotEmpty
                          ? pokemon.typeImage2
                          : null,
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              '${context.t().weight}: ${MeasurementFormatter.formatWeight(pokemon.weightInKg, unitSystem, locale: locale)}',
            ),
            const SizedBox(height: 4),
            Text(
              '${context.t().height}: ${MeasurementFormatter.formatHeight(pokemon.heightInMeters, unitSystem, locale: locale)}',
            ),
            const Divider(height: 24),
            Text(
              context.t().baseStats,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (pokemon.stats.length < 6)
              Text(context.t().statsNotAvailable)
            else ...[
              for (var i = 0; i < StatKind.values.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CompactStatRow(
                    kind: StatKind.values[i],
                    value: pokemon.stats[i],
                    locale: locale,
                  ),
                ),
              const Divider(height: 16),
              Text(
                '${context.t().compareTotal}: ${MeasurementFormatter.formatInteger(pokemon.stats.reduce((a, b) => a + b), locale: locale)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  const _SlotHeader({required this.entry, required this.pokemonName});

  final PokemonIndexEntry entry;
  final String pokemonName;

  Future<void> _shareEntry(BuildContext context) async {
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.formattedId,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                pokemonName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: context.t().shareLink,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: context.t().shareLink,
              icon: const Icon(Icons.link_rounded),
              onPressed: () => _shareEntry(context),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: context.t().compareRemove,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: context.t().compareRemove,
              icon: const Icon(Icons.close_rounded),
              onPressed: () =>
                  context.read<ComparisonCubit>().removeEntry(entry.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonEmptyView extends StatelessWidget {
  const _ComparisonEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              context.t().compareEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(context.t().compareEmptyMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => context.push('/pokedex'),
              child: Text(context.t().browsePokedex),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonEmptySlot extends StatelessWidget {
  const _ComparisonEmptySlot();

  @override
  Widget build(BuildContext context) {
    return _slotCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => context.push('/pokedex'),
            child: Text(context.t().browsePokedex),
          ),
        ],
      ),
    );
  }
}
