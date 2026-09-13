import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
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
  });

  final Pokemon pokemon;
  final Color textColor;
  final CryAudioController audioController;
  final Color typeColor;
  final VoidCallback onFormTap;

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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Height and Weight cards
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

          // Core Info card
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
                    value: pokemon.isDefault ? context.t().yes : context.t().no,
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Abilities
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
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ability.isHidden
                      ? Colors.amber.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest
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
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Cries Section
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

          // Form & shiny selector button
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
