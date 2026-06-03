import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailItemsGamesTab extends StatelessWidget {
  const DetailItemsGamesTab({
    super.key,
    required this.pokemon,
    required this.textColor,
    required this.encounters,
    required this.isLoadingEncounters,
    required this.encountersError,
  });

  final Pokemon pokemon;
  final Color textColor;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingEncounters;
  final String? encountersError;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Species
          Text(
            context.t().species,
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
                    label: context.t().species,
                    value: pokemon.speciesName.toUpperCase(),
                    textColor: textColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Encounter Areas
          Text(
            context.t().locationAreaEncounters,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildEncounters(
              context, encounters, isLoadingEncounters, encountersError),
          const SizedBox(height: 20),

          // Held items
          Text(
            context.t().heldItems,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          if (pokemon.heldItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                context.t().heldItemsEmpty,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pokemon.heldItems.length,
              itemBuilder: (context, index) {
                final item = pokemon.heldItems[index];
                final capitalizedItem =
                    item.name.replaceAll('-', ' ').toUpperCase();
                return SurfaceCard(
                  borderRadius: 12,
                  child: ListTile(
                    leading: const Icon(Icons.gif_box_outlined),
                    title: Text(capitalizedItem,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${context.t().versionLabel}: ${context.translateGameVersion(item.version)}'),
                    trailing: Text(
                      '${item.rarity}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),

          // Game Indices
          Text(
            context.t().gameIndices,
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
            children: pokemon.gameIndices.map((game) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getGameColor(game).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getGameColor(game).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  context.translateGameVersion(game).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _getGameColor(game),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounters(
    BuildContext context,
    List<PokemonEncounter>? encounters,
    bool isLoadingEncounters,
    String? encountersError,
  ) {
    if (isLoadingEncounters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (encountersError != null) {
      return Text(
        'Error: $encountersError',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (encounters == null || encounters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          context.t().encountersEmpty,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: encounters.length,
      itemBuilder: (context, index) {
        final encounter = encounters[index];
        return SurfaceCard(
          borderRadius: 12,
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              context.translateLocation(encounter.rawLocationAreaName),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: encounter.versions.map((version) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    context.translateGameVersion(version).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getGameColor(String game) {
    switch (game.toLowerCase()) {
      case 'red':
      case 'firered':
        return Colors.red;
      case 'blue':
      case 'leafgreen':
        return Colors.blue;
      case 'yellow':
        return Colors.amber.shade700;
      case 'gold':
      case 'heartgold':
        return Colors.orange.shade400;
      case 'silver':
      case 'soulsilver':
        return Colors.blueGrey;
      case 'crystal':
        return Colors.cyan;
      case 'ruby':
      case 'omega-ruby':
        return Colors.red.shade900;
      case 'sapphire':
      case 'alpha-sapphire':
        return Colors.blue.shade900;
      case 'emerald':
        return Colors.green.shade800;
      case 'diamond':
        return Colors.lightBlue;
      case 'pearl':
        return Colors.pink.shade300;
      case 'platinum':
        return Colors.purple.shade300;
      case 'black':
      case 'black-2':
        return Colors.black;
      case 'white':
      case 'white-2':
        return Colors.grey.shade400;
      case 'x':
        return Colors.blue.shade800;
      case 'y':
        return Colors.red.shade800;
      case 'sun':
      case 'ultra-sun':
        return Colors.orange;
      case 'moon':
      case 'ultra-moon':
        return Colors.indigo;
      case 'sword':
        return Colors.cyan.shade800;
      case 'shield':
        return Colors.red.shade700;
      case 'scarlet':
        return Colors.redAccent;
      case 'violet':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
