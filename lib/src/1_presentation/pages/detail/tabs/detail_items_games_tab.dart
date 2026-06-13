import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

class DetailItemsGamesTab extends StatelessWidget {
  const DetailItemsGamesTab({
    super.key,
    required this.pokemon,
    required this.textColor,
    required this.encounters,
    required this.isLoadingEncounters,
    required this.encountersFailure,
  });

  final Pokemon pokemon;
  final Color textColor;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingEncounters;
  final PokemonFailure? encountersFailure;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SpeciesSection(pokemon: pokemon, textColor: textColor),
          const SizedBox(height: 20),
          _EncountersSection(
            encounters: encounters,
            isLoadingEncounters: isLoadingEncounters,
            encountersFailure: encountersFailure,
            textColor: textColor,
          ),
          const SizedBox(height: 20),
          _HeldItemsSection(pokemon: pokemon, textColor: textColor),
          const SizedBox(height: 20),
          _GameIndicesSection(pokemon: pokemon, textColor: textColor),
        ],
      ),
    );
  }
}

class _SpeciesSection extends StatelessWidget {
  const _SpeciesSection({required this.pokemon, required this.textColor});

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}

class _EncountersSection extends StatelessWidget {
  const _EncountersSection({
    required this.encounters,
    required this.isLoadingEncounters,
    required this.encountersFailure,
    required this.textColor,
  });

  final List<PokemonEncounter>? encounters;
  final bool isLoadingEncounters;
  final PokemonFailure? encountersFailure;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t().locationAreaEncounters,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoadingEncounters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (encountersFailure != null) {
      return Text(
        encountersFailure!.localizedMessage(context),
        style: const TextStyle(color: Colors.red),
      );
    }

    if (encounters == null || encounters!.isEmpty) {
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

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: encounters!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final encounter = encounters![index];
        return SurfaceCard(
          borderRadius: 12,
          margin: EdgeInsets.zero,
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
}

class _HeldItemsSection extends StatelessWidget {
  const _HeldItemsSection({required this.pokemon, required this.textColor});

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}

class _GameIndicesSection extends StatelessWidget {
  const _GameIndicesSection({required this.pokemon, required this.textColor});

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final color = gameVersionColor(game);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                context.translateGameVersion(game).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
