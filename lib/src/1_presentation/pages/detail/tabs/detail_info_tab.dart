import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_tab_scroll_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Info tab of the detail page: size, Pokédex entry, species data, forms,
/// sprites, abilities and cries.
class DetailInfoTab extends StatelessWidget {
  const DetailInfoTab({
    super.key,
    required this.pokemon,
    required this.audioController,
    required this.onFormTap,
    this.selectedFormName,
  });

  final Pokemon pokemon;
  final CryAudioController audioController;
  final VoidCallback onFormTap;
  final String? selectedFormName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createSpeciesCubit(pokemon.speciesUrl),
      child: _DetailInfoTabContent(
        pokemon: pokemon,
        audioController: audioController,
        onFormTap: onFormTap,
        selectedFormName: selectedFormName,
      ),
    );
  }
}

class _DetailInfoTabContent extends StatelessWidget {
  const _DetailInfoTabContent({
    required this.pokemon,
    required this.audioController,
    required this.onFormTap,
    this.selectedFormName,
  });

  final Pokemon pokemon;
  final CryAudioController audioController;
  final VoidCallback onFormTap;
  final String? selectedFormName;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final unitSystem = context.select<PreferencesCubit, UnitSystem>(
      (cubit) => cubit.state.unitSystem,
    );
    final locale = Localizations.localeOf(context).languageCode;
    final isAlternateForm =
        selectedFormName != null && selectedFormName != pokemon.name;

    return DetailTabScrollView(
      storageKey: 'detail_info',
      slivers: [
        SliverList.list(
          children: [
            DetailGameVersionSelector(typeColor: accent),
            const SizedBox(height: 16),
            if (isAlternateForm) ...[
              _FormNoticeBanner(formName: selectedFormName!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _MeasureCard(
                    icon: Icons.scale_rounded,
                    value: MeasurementFormatter.formatWeight(
                      pokemon.weightInKg,
                      unitSystem,
                      locale: locale,
                    ),
                    label: t.weight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MeasureCard(
                    icon: Icons.straighten_rounded,
                    value: MeasurementFormatter.formatHeight(
                      pokemon.heightInMeters,
                      unitSystem,
                      locale: locale,
                    ),
                    label: t.height,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SpeciesSection(pokemon: pokemon),
            if (pokemon.forms.length > 1) ...[
              AlternateFormsWidget(
                pokemon: pokemon,
                typeColor: accent,
                textColor: theme.colorScheme.onSurface,
                selectedFormName: selectedFormName,
              ),
              const SizedBox(height: 24),
            ],
            SpriteGalleryWidget(pokemon: pokemon),
            const SizedBox(height: 24),
            SectionTitle(t.abilities),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ability in pokemon.abilities)
                  _AbilityChip(ability: ability),
              ],
            ),
            const SizedBox(height: 24),
            SectionTitle(t.cries),
            Row(
              children: [
                Expanded(
                  child: CryPlayButton(
                    controller: audioController,
                    cryUrl: pokemon.cry,
                    label: t.cryLatest,
                    pokemonName: pokemon.name,
                  ),
                ),
                if (pokemon.cryLegacy != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: CryPlayButton(
                      controller: audioController,
                      cryUrl: pokemon.cryLegacy!,
                      label: t.cryLegacy,
                      pokemonName: pokemon.name,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onFormTap,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text(
                t.formSelectorTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// States that stats, moves and abilities belong to the base species.
class _FormNoticeBanner extends StatelessWidget {
  const _FormNoticeBanner({required this.formName});

  final String formName;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.t().baseSpeciesDataNotice(
                formName: formatFormName(context, formName),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureCard extends StatelessWidget {
  const _MeasureCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      margin: EdgeInsets.zero,
      alpha: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pokédex entry, species data and evolution chain.
class _SpeciesSection extends StatelessWidget {
  const _SpeciesSection({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final selectedVersion = context.select<DetailGameVersionCubit, String>(
      (cubit) => cubit.state.selectedVersion,
    );
    final speciesState = context.watch<SpeciesCubit>().state;

    final baseExp = pokemon.baseExperience;
    final aboutRows = <LabelValueRow>[
      LabelValueRow(
        label: t.baseExp,
        value: baseExp != null ? t.baseExpValue(value: baseExp) : '-',
      ),
      if (speciesState case SpeciesLoaded(:final species)) ...[
        if (species.generation != null)
          LabelValueRow(
            label: t.generation,
            value: species.generation!.toDisplayCase(),
          ),
        if (species.habitat != null)
          LabelValueRow(label: t.habitat, value: species.habitat!.capitalize()),
        if (species.captureRate != null)
          LabelValueRow(label: t.captureRate, value: '${species.captureRate}'),
        if (species.baseHappiness != null)
          LabelValueRow(
            label: t.baseHappiness,
            value: '${species.baseHappiness}',
          ),
      ],
      LabelValueRow(
        label: t.defaultForm,
        value: pokemon.isDefault ? t.yes : t.no,
      ),
    ];

    final aboutCard = SurfaceCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final (index, row) in aboutRows.indexed) ...[
              if (index > 0) const Divider(),
              row,
            ],
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (speciesState) {
          SpeciesInitial() => const SizedBox.shrink(),
          SpeciesLoading() => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          SpeciesError(:final failure, :final message) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _SpeciesErrorCard(
              message: failure?.localizedMessage(context) ?? message,
              onRetry: () =>
                  context.read<SpeciesCubit>().fetchSpecies(pokemon.speciesUrl),
            ),
          ),
          SpeciesLoaded(:final species) => _FlavorTextSection(
            genus: species.genusFor(locale),
            flavorText: species.flavorTextFor(
              languageCode: locale,
              version: selectedVersion,
            ),
          ),
        },
        SectionTitle(t.about),
        aboutCard,
        const SizedBox(height: 24),
        if (speciesState case SpeciesLoaded(
          species: PokemonSpecies(:final evolutionChainUrl?),
        )) ...[
          EvolutionChainWidget(
            evolutionChainUrl: evolutionChainUrl,
            currentPokemonName: pokemon.name,
            typeColor: theme.colorScheme.primary,
            textColor: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _FlavorTextSection extends StatelessWidget {
  const _FlavorTextSection({required this.genus, required this.flavorText});

  final String genus;
  final String flavorText;

  @override
  Widget build(BuildContext context) {
    if (genus.isEmpty && flavorText.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(context.t().flavorText),
          SurfaceCard(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (genus.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        genus,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (flavorText.isNotEmpty)
                    Text(
                      flavorText,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeciesErrorCard extends StatelessWidget {
  const _SpeciesErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SurfaceCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: error),
              ),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(context.t().retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  const _AbilityChip({required this.ability});

  final PokemonAbility ability;

  @override
  Widget build(BuildContext context) {
    final name = context.translateAbility(ability.name);
    final label = ability.isHidden
        ? '$name (${context.t().abilityHidden})'
        : name;
    return ActionChip(
      avatar: Icon(
        ability.isHidden
            ? Icons.visibility_off_outlined
            : Icons.info_outline_rounded,
        size: 16,
      ),
      label: Text(label),
      side: ability.isHidden
          ? BorderSide(color: Theme.of(context).colorScheme.primary)
          : null,
      onPressed: () => AbilityDetailBottomSheet.show(
        context,
        abilityName: ability.name,
        displayName: name,
        isHidden: ability.isHidden,
      ),
    );
  }
}
