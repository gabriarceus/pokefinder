import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/4_repository/services/audio_player.dart';

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
                  _buildInfoRow(
                    context,
                    label: context.t().baseExp,
                    value: pokemon.baseExperience != null
                        ? '${pokemon.baseExperience} XP'
                        : '-',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    label: context.t().defaultForm,
                    value: pokemon.isDefault ? context.t().yes : context.t().no,
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

  Widget _buildInfoRow(BuildContext context,
      {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailStatsTab extends StatelessWidget {
  const DetailStatsTab({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  int _calculateMinStat(String statName, int baseValue) {
    if (statName.toLowerCase() == 'hp') {
      if (baseValue == 1) return 1; // Shedinja
      return 2 * baseValue + 110;
    }
    return ((2 * baseValue + 5) * 0.9).floor();
  }

  int _calculateMaxStat(String statName, int baseValue) {
    if (statName.toLowerCase() == 'hp') {
      if (baseValue == 1) return 1; // Shedinja
      return 2 * baseValue + 204;
    }
    return ((2 * baseValue + 99) * 1.1).floor();
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon.stats.length < 6) {
      return Center(child: Text(context.t().statsNotAvailable));
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t().baseStats,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 70),
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 40,
                child: Text(
                  'Base',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  context.t().statsMin,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  context.t().statsMax,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatRow(context, context.t().statHp, 'hp', pokemon.stats[0]),
          const SizedBox(height: 12),
          _buildStatRow(context, context.t().statAttack, 'atk', pokemon.stats[1]),
          const SizedBox(height: 12),
          _buildStatRow(context, context.t().statDefense, 'def', pokemon.stats[2]),
          const SizedBox(height: 12),
          _buildStatRow(context, context.t().statSpAtk, 'spatk', pokemon.stats[3]),
          const SizedBox(height: 12),
          _buildStatRow(context, context.t().statSpDef, 'spdef', pokemon.stats[4]),
          const SizedBox(height: 12),
          _buildStatRow(context, context.t().statSpeed, 'speed', pokemon.stats[5]),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String statKey, int value) {
    Color statColor;
    if (value > 90) {
      statColor = Colors.green;
    } else if (value > 50) {
      statColor = Colors.amber;
    } else {
      statColor = Colors.red;
    }

    final minVal = _calculateMinStat(statKey, value);
    final maxVal = _calculateMaxStat(statKey, value);

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
        const SizedBox(width: 8),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value / 255.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: val,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  color: statColor,
                  minHeight: 8,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            minVal.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            maxVal.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class DetailMovesTab extends StatefulWidget {
  const DetailMovesTab({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  @override
  State<DetailMovesTab> createState() => _DetailMovesTabState();
}

class _DetailMovesTabState extends State<DetailMovesTab> {
  String _searchQuery = '';
  String _selectedMethod = 'all';
  String? _selectedVersionGroup;

  @override
  void initState() {
    super.initState();
    final versionGroups = widget.pokemon.moves.map((m) => m.versionGroup).toSet().toList();
    if (versionGroups.isNotEmpty) {
      if (versionGroups.contains('diamond-pearl')) {
        _selectedVersionGroup = 'diamond-pearl';
      } else {
        _selectedVersionGroup = versionGroups.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final versionGroups = widget.pokemon.moves.map((m) => m.versionGroup).toSet().toList();

    final uniqueMoves = <String, PokemonMove>{};
    for (final move in widget.pokemon.moves) {
      if (move.versionGroup != _selectedVersionGroup) continue;
      final translatedName = context.translateMove(move.name).toLowerCase();
      final matchesSearch =
          move.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          translatedName.contains(_searchQuery.toLowerCase());
      if (!matchesSearch) continue;
      if (_selectedMethod != 'all' && move.learnMethod != _selectedMethod) continue;

      final existing = uniqueMoves[move.name];
      if (existing == null ||
          move.levelLearnedAt > 0 &&
              (existing.levelLearnedAt == 0 ||
                  move.levelLearnedAt < existing.levelLearnedAt)) {
        uniqueMoves[move.name] = move;
      }
    }

    final filteredMoves = uniqueMoves.values.toList();

    filteredMoves.sort((a, b) {
      if (a.learnMethod == 'level-up' && b.learnMethod == 'level-up') {
        return a.levelLearnedAt.compareTo(b.levelLearnedAt);
      }
      return a.name.compareTo(b.name);
    });

    final methods = ['all', 'level-up', 'machine', 'tutor', 'egg'];

    return Column(
      children: [
        if (versionGroups.isNotEmpty) ...[
          Row(
            children: [
              Text(
                context.t().gameSelectorLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedVersionGroup,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: versionGroups.map((vg) {
                    return DropdownMenuItem<String>(
                      value: vg,
                      child: Text(
                        context.translateGameVersion(vg),
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedVersionGroup = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          decoration: InputDecoration(
            hintText: context.t().movesSearchPlaceholder,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: methods.map((method) {
              final isSelected = _selectedMethod == method;
              String label = method;
              if (method == 'all') label = 'Tutte';
              if (method == 'level-up') label = 'Livello';
              if (method == 'machine') label = 'MT';
              if (method == 'tutor') label = 'Esperto';
              if (method == 'egg') label = 'Uovo';

              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMethod = method;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredMoves.isEmpty
              ? Center(child: Text(context.t().movesSearchEmpty))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filteredMoves.length,
                  itemBuilder: (context, index) {
                    final move = filteredMoves[index];
                    final capitalizedName = context.translateMove(move.name);

                    String learnDetail = '';
                    if (move.learnMethod == 'level-up') {
                      learnDetail = 'Lvl ${move.levelLearnedAt}';
                    } else if (move.learnMethod == 'machine') {
                      learnDetail = 'MT';
                    } else if (move.learnMethod == 'tutor') {
                      learnDetail = 'Tutor';
                    } else if (move.learnMethod == 'egg') {
                      learnDetail = 'Uovo';
                    } else {
                      learnDetail = move.learnMethod;
                    }

                    return Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          capitalizedName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            learnDetail,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class DetailItemsGamesTab extends StatelessWidget {
  const DetailItemsGamesTab({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final locator = getIt<IPokemonRepository>();
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
                  _buildDetailRow(
                    context,
                    label: context.t().species,
                    value: pokemon.speciesName.toUpperCase(),
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
          FutureBuilder<Either<PokemonFailure, List<PokemonEncounter>>>(
            future: locator.getEncounters(pokemon.locationAreaEncounters),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Text(
                  context.t().encountersEmpty,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                );
              }

              final result = snapshot.data!;
              return result.fold(
                (failure) => Text(
                  'Error: ${failure.message}',
                  style: const TextStyle(color: Colors.red),
                ),
                (encounters) {
                  if (encounters.isEmpty) {
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
                      return Card(
                        elevation: 0,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                },
              );
            },
          ),
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
                return Card(
                  elevation: 0,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.gif_box_outlined),
                    title: Text(capitalizedItem,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${context.t().versionLabel}: ${context.translateGameVersion(item.version)}'),
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

  Widget _buildDetailRow(BuildContext context,
      {required String label, required String value, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          onTap != null
              ? InkWell(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ],
      ),
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

class CryPlayButton extends StatefulWidget {
  const CryPlayButton({
    super.key,
    required this.player,
    required this.cryUrl,
    required this.label,
  });

  final AudioPlayer player;
  final String cryUrl;
  final String label;

  @override
  State<CryPlayButton> createState() => _CryPlayButtonState();
}

class _CryPlayButtonState extends State<CryPlayButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        final processingState = playerState?.processingState ?? ProcessingState.idle;
        final sequence = widget.player.audioSource?.sequence;
        final isThisSource = sequence != null &&
            sequence.isNotEmpty &&
            sequence.first is UriAudioSource &&
            (sequence.first as UriAudioSource).uri.toString() == widget.cryUrl;

        final isCompleted = isThisSource && processingState == ProcessingState.completed;
        final isCurrentlyPlaying = playing && isThisSource && processingState != ProcessingState.completed;

        return Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      isCurrentlyPlaying
                          ? Icons.stop_rounded
                          : isCompleted
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      if (isCurrentlyPlaying) {
                        await widget.player.stop();
                      } else if (isCompleted) {
                        await widget.player.seek(Duration.zero);
                        await widget.player.play();
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        await setupAudioPlayer(widget.player, widget.cryUrl);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        await widget.player.play();
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color itemColorExtractor(Color? backgroundColor) {
  return backgroundColor!.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
