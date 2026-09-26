import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_tab_scroll_view.dart';
import 'package:pokefinder/src/1_presentation/theme/readable_color.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_cubit.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

/// "Where to find" tab of the detail page: encounters, held items and the
/// games that include the Pokémon.
class DetailItemsGamesTab extends StatelessWidget {
  const DetailItemsGamesTab({
    super.key,
    required this.pokemon,
    required this.encounters,
    required this.isLoadingEncounters,
    required this.encountersFailure,
  });

  final Pokemon pokemon;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingEncounters;
  final PokemonFailure? encountersFailure;

  @override
  Widget build(BuildContext context) {
    final selectedVersion = context.select<DetailGameVersionCubit, String>(
      (cubit) => cubit.state.selectedVersion,
    );

    return DetailTabScrollView(
      storageKey: 'detail_items_games',
      slivers: [
        SliverList.list(
          children: [
            DetailGameVersionSelector(
              typeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _EncountersSection(
              encounters: encounters,
              isLoadingEncounters: isLoadingEncounters,
              encountersFailure: encountersFailure,
              selectedVersion: selectedVersion,
            ),
            const SizedBox(height: 24),
            _HeldItemsSection(
              pokemon: pokemon,
              selectedVersion: selectedVersion,
            ),
            const SizedBox(height: 24),
            _GameIndicesSection(pokemon: pokemon),
          ],
        ),
      ],
    );
  }
}

/// Muted italic text for a section without entries.
class _EmptySectionText extends StatelessWidget {
  const _EmptySectionText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _EncountersSection extends StatelessWidget {
  const _EncountersSection({
    required this.encounters,
    required this.isLoadingEncounters,
    required this.encountersFailure,
    required this.selectedVersion,
  });

  final List<PokemonEncounter>? encounters;
  final bool isLoadingEncounters;
  final PokemonFailure? encountersFailure;
  final String selectedVersion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(context.t().locationAreaEncounters),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    if (isLoadingEncounters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final failure = encountersFailure;
    if (failure != null) {
      return SurfaceCard(
        borderRadius: 12,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  failure.localizedMessage(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.read<PokemonDetailBloc>().add(
                  RetryPokemonEncountersEvent(),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(t.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    final isAllVersions = selectedVersion == DetailGameVersionState.allVersions;
    final displayedEncounters = isAllVersions || encounters == null
        ? encounters
        : encounters!
              .where((e) => e.versions.contains(selectedVersion))
              .toList();

    if (displayedEncounters == null || displayedEncounters.isEmpty) {
      return _EmptySectionText(
        !isAllVersions && (encounters?.isNotEmpty ?? false)
            ? t.encountersUnavailableForVersion
            : t.encountersEmpty,
      );
    }

    final primary = theme.colorScheme.primary;
    return Column(
      children: [
        for (final encounter in displayedEncounters)
          SurfaceCard(
            borderRadius: 12,
            margin: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(
                context.translateLocation(encounter.rawLocationAreaName),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final version in encounter.versions)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.translateGameVersion(version),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HeldItemsSection extends StatelessWidget {
  const _HeldItemsSection({
    required this.pokemon,
    required this.selectedVersion,
  });

  final Pokemon pokemon;
  final String selectedVersion;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    final isAllVersions = selectedVersion == DetailGameVersionState.allVersions;
    final displayedHeldItems = isAllVersions
        ? pokemon.heldItems
        : pokemon.heldItems
              .where((item) => item.version == selectedVersion)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(t.heldItems),
        if (displayedHeldItems.isEmpty)
          _EmptySectionText(
            !isAllVersions && pokemon.heldItems.isNotEmpty
                ? t.heldItemsUnavailableForVersion
                : t.heldItemsEmpty,
          )
        else
          for (final item in displayedHeldItems)
            SurfaceCard(
              borderRadius: 12,
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: const Icon(Icons.backpack_outlined),
                title: Text(
                  context.translateItem(item.name),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${t.versionLabel}: ${context.translateGameVersion(item.version)}',
                ),
                trailing: Text(
                  '${item.rarity}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _GameIndicesSection extends StatelessWidget {
  const _GameIndicesSection({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(context.t().gameIndices),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final game in pokemon.gameIndices)
              _GameBadge(label: context.translateGameVersion(game), game: game),
          ],
        ),
      ],
    );
  }
}

class _GameBadge extends StatelessWidget {
  const _GameBadge({required this.label, required this.game});

  final String label;
  final String game;

  @override
  Widget build(BuildContext context) {
    final color = gameVersionColor(game);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color.readableOn(Theme.of(context).brightness),
        ),
      ),
    );
  }
}
