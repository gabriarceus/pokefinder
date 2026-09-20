import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class DetailInfoTab extends StatelessWidget {
  const DetailInfoTab({
    super.key,
    required this.pokemon,
    required this.textColor,
    required this.audioController,
    required this.typeColor,
    required this.onFormTap,
    this.selectedFormName,
  });

  final Pokemon pokemon;
  final Color textColor;
  final CryAudioController audioController;
  final Color typeColor;
  final VoidCallback onFormTap;
  final String? selectedFormName;

  /// Returns a darkened version of [typeColor] when it has high luminance on a
  /// light theme, so that text/icons using it remain visible on card surfaces.
  Color _visibleTypeColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final luminance = typeColor.computeLuminance();
    if (brightness == Brightness.light && luminance > 0.45) {
      final hsl = HSLColor.fromColor(typeColor);
      return hsl
          .withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation + 0.15).clamp(0.0, 1.0))
          .toColor();
    }
    return typeColor;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _visibleTypeColor(context);

    return BlocProvider(
      create: (context) => createSpeciesCubit(pokemon.speciesUrl),
      child: _DetailInfoTabContent(
        pokemon: pokemon,
        textColor: textColor,
        audioController: audioController,
        typeColor: typeColor,
        effectiveColor: effectiveColor,
        onFormTap: onFormTap,
        selectedFormName: selectedFormName,
      ),
    );
  }
}

class _DetailInfoTabContent extends StatelessWidget {
  const _DetailInfoTabContent({
    required this.pokemon,
    required this.textColor,
    required this.audioController,
    required this.typeColor,
    required this.effectiveColor,
    required this.onFormTap,
    this.selectedFormName,
  });

  final Pokemon pokemon;
  final Color textColor;
  final CryAudioController audioController;
  final Color typeColor;
  final Color effectiveColor;
  final VoidCallback onFormTap;
  final String? selectedFormName;

  @override
  Widget build(BuildContext context) {
    UnitSystem unitSystem = UnitSystem.metric;
    try {
      unitSystem = context.watch<PreferencesCubit>().state.unitSystem;
    } catch (_) {}

    final locale = Localizations.localeOf(context).languageCode;
    final formattedWeight = MeasurementFormatter.formatWeight(
      pokemon.weightInKg,
      unitSystem,
      locale: locale,
    );
    final formattedHeight = MeasurementFormatter.formatHeight(
      pokemon.heightInMeters,
      unitSystem,
      locale: locale,
    );

    String selectedVersion = 'all';
    try {
      selectedVersion = context.select<DetailGameVersionCubit, String>(
        (cubit) => cubit.state.selectedVersion,
      );
    } catch (_) {}

    final isAlternateForm =
        selectedFormName != null && selectedFormName != pokemon.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Alternate Form Consistency Banner (§8.4)
          if (isAlternateForm) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: effectiveColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t().baseSpeciesDataNotice(
                        formName: formatFormName(context, selectedFormName!),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 1. Height and Weight cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard(
                context,
                icon: Icons.scale_rounded,
                value: formattedWeight,
                label: context.t().weight,
              ),
              _buildInfoCard(
                context,
                icon: Icons.straighten_rounded,
                value: formattedHeight,
                label: context.t().height,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Pokédex Description & Species Information (§8.1)
          BlocBuilder<SpeciesCubit, SpeciesState>(
            builder: (context, speciesState) {
              if (speciesState is SpeciesLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (speciesState is SpeciesError) {
                final errorMessage = speciesState.failure != null
                    ? speciesState.failure!.localizedMessage(context)
                    : speciesState.message;
                return SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<SpeciesCubit>().fetchSpecies(
                              pokemon.speciesUrl,
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(context.t().retryButton),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (speciesState is SpeciesLoaded) {
                final species = speciesState.species;
                final flavorText = species.flavorTextFor(
                  languageCode: locale,
                  version: selectedVersion,
                );
                final genus = species.genusFor(locale);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (flavorText.isNotEmpty || genus.isNotEmpty) ...[
                      Text(
                        context.t().flavorText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SurfaceCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (genus.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: effectiveColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    genus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: effectiveColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              if (flavorText.isNotEmpty)
                                Text(
                                  flavorText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: textColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Core Info card enriched with species attributes
                    Text(
                      context.t().about,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            LabelValueRow(
                              label: context.t().baseExp,
                              value: pokemon.baseExperience != null
                                  ? '${pokemon.baseExperience} XP'
                                  : '-',
                              textColor: textColor,
                            ),
                            if (species.generation != null) ...[
                              const Divider(),
                              LabelValueRow(
                                label: context.t().generation,
                                value: species.generation!.toDisplayCase(),
                                textColor: textColor,
                              ),
                            ],
                            if (species.habitat != null) ...[
                              const Divider(),
                              LabelValueRow(
                                label: context.t().habitat,
                                value: species.habitat!.capitalize(),
                                textColor: textColor,
                              ),
                            ],
                            if (species.captureRate != null) ...[
                              const Divider(),
                              LabelValueRow(
                                label: context.t().captureRate,
                                value: '${species.captureRate}',
                                textColor: textColor,
                              ),
                            ],
                            if (species.baseHappiness != null) ...[
                              const Divider(),
                              LabelValueRow(
                                label: context.t().baseHappiness,
                                value: '${species.baseHappiness}',
                                textColor: textColor,
                              ),
                            ],
                            const Divider(),
                            LabelValueRow(
                              label: context.t().defaultForm,
                              value: pokemon.isDefault
                                  ? context.t().yes
                                  : context.t().no,
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Evolution Chain Visualization (§8.2)
                    if (species.evolutionChainUrl != null) ...[
                      EvolutionChainWidget(
                        evolutionChainUrl: species.evolutionChainUrl,
                        currentPokemonName: pokemon.name,
                        typeColor: effectiveColor,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                );
              }

              // Fallback default About card when species is initial/unloaded
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t().about,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          LabelValueRow(
                            label: context.t().baseExp,
                            value: pokemon.baseExperience != null
                                ? '${pokemon.baseExperience} XP'
                                : '-',
                            textColor: textColor,
                          ),
                          const Divider(),
                          LabelValueRow(
                            label: context.t().defaultForm,
                            value: pokemon.isDefault
                                ? context.t().yes
                                : context.t().no,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),

          // 2.1 Alternate Forms Gallery (§8.5)
          if (pokemon.forms.length > 1) ...[
            AlternateFormsWidget(
              pokemon: pokemon,
              typeColor: effectiveColor,
              textColor: textColor,
              selectedFormName: selectedFormName,
            ),
            const SizedBox(height: 20),
          ],

          // 2.2 Artwork & sprite-variant gallery (Task 11.1)
          SpriteGalleryWidget(pokemon: pokemon, textColor: textColor),
          const SizedBox(height: 20),

          // 3. Abilities with tap-to-inspect (§8.3)
          Text(
            context.t().abilities,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemon.abilities.map((ability) {
              final capitalizedAbility = context
                  .translateAbility(ability.name)
                  .toUpperCase();
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    AbilityDetailBottomSheet.show(
                      context,
                      abilityName: ability.name,
                      displayName: capitalizedAbility,
                      isHidden: ability.isHidden,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ability.isHidden
                          ? Colors.amber.withValues(alpha: 0.1)
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ability.isHidden
                            ? Colors.amber.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (ability.isHidden) ...[
                          const Icon(
                            Icons.visibility_off_outlined,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          capitalizedAbility,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ability.isHidden
                                ? Colors.amber.shade900
                                : textColor,
                          ),
                        ),
                        if (ability.isHidden) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${context.t().abilityHidden})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: ability.isHidden
                              ? Colors.amber.shade900.withValues(alpha: 0.7)
                              : textColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 4. Cries Section
          Text(
            context.t().cries,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CryPlayButton(
                  controller: audioController,
                  cryUrl: pokemon.cry,
                  label: context.t().cryLatest,
                  pokemonName: pokemon.name,
                ),
              ),
              if (pokemon.cryLegacy != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: CryPlayButton(
                    controller: audioController,
                    cryUrl: pokemon.cryLegacy!,
                    label: context.t().cryLegacy,
                    pokemonName: pokemon.name,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // 5. Form & shiny selector button
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onFormTap,
              style: FilledButton.styleFrom(
                backgroundColor: effectiveColor.withValues(alpha: 0.12),
                foregroundColor: effectiveColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 20,
                    color: effectiveColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.t().formSelectorTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
