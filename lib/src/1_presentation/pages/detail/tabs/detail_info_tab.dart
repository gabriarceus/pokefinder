import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailInfoTab extends StatelessWidget {
  const DetailInfoTab({
    super.key,
    required this.pokemon,
    required this.textColor,
    required this.player,
  });

  final Pokemon pokemon;
  final Color textColor;
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
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
                value: '${pokemon.weight / 10} kg',
                label: context.t().weight,
              ),
              _buildInfoCard(
                context,
                icon: Icons.straighten_rounded,
                value: '${pokemon.height / 10} m',
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
          Card(
            elevation: 0,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              final capitalizedAbility =
                  context.translateAbility(ability.name).toUpperCase();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ability.isHidden) ...[
                      const Icon(Icons.visibility_off_outlined,
                          size: 16, color: Colors.amber),
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
                  player: player,
                  cryUrl: pokemon.cry,
                  label: context.t().cryLatest,
                ),
              ),
              if (pokemon.cryLegacy != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: CryPlayButton(
                    player: player,
                    cryUrl: pokemon.cryLegacy!,
                    label: context.t().cryLegacy,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon, required String value, required String label}) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: textColor.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              Text(
                label,
                style: TextStyle(
                    fontSize: 12, color: textColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
