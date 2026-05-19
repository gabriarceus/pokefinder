import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailComponents extends StatelessWidget {
  const DetailComponents({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t().about,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Gap(16),
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
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t().pokemonCry,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            PlaybackButton(player: player),
          ],
        ),
        const Gap(24),
        Text(
          context.t().baseStats,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const Gap(16),
        if (pokemon.stats.length >= 6) ...[
          _buildStatRow(context, context.t().statHp, pokemon.stats[0]),
          const Gap(8),
          _buildStatRow(context, context.t().statAttack, pokemon.stats[1]),
          const Gap(8),
          _buildStatRow(context, context.t().statDefense, pokemon.stats[2]),
          const Gap(8),
          _buildStatRow(context, context.t().statSpAtk, pokemon.stats[3]),
          const Gap(8),
          _buildStatRow(context, context.t().statSpDef, pokemon.stats[4]),
          const Gap(8),
          _buildStatRow(context, context.t().statSpeed, pokemon.stats[5]),
        ] else
          Text(context.t().statsNotAvailable),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String value, required String label}) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: textColor.withValues(alpha: 0.7)),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value) {
    Color statColor;
    if (value > 90) {
      statColor = Colors.green;
    } else if (value > 50) {
      statColor = Colors.amber;
    } else {
      statColor = Colors.red;
    }

    return Row(
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
        const Gap(8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 255.0, // 255 is approx max stat
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: statColor,
              minHeight: 8,
            ),
          ),
        ),
        const Gap(16),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

Color itemColorExtractor(Color? backgroundColor) {
  return backgroundColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
