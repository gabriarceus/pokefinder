import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/l10n/translation_helper.dart';

class DetailMovesTab extends StatelessWidget {
  const DetailMovesTab({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailMovesCubit(moves: pokemon.moves),
      child: BlocBuilder<DetailMovesCubit, DetailMovesState>(
        builder: (context, state) {
          final cubit = context.read<DetailMovesCubit>();
          final versionGroups = state.allMoves.map((m) => m.versionGroup).toSet().toList();
          final methods = cubit.getAvailableMethods();
          final locale = Localizations.localeOf(context).languageCode;

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
                        initialValue: state.selectedVersionGroup,
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
                          if (val != null) {
                            cubit.updateSelectedVersionGroup(val, locale);
                          }
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
                  cubit.updateSearchQuery(val, locale);
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: methods.map((method) {
                    final isSelected = state.selectedMethod == method;
                    final label = switch (method) {
                      'all' => 'Tutte',
                      'level-up' => 'Livello',
                      'machine' => 'MT',
                      'tutor' => 'Esperto',
                      'egg' => 'Uovo',
                      _ => method,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            cubit.updateSelectedMethod(method, locale);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: state.filteredMoves.isEmpty
                    ? Center(child: Text(context.t().movesSearchEmpty))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: state.filteredMoves.length,
                        itemBuilder: (context, index) {
                          final move = state.filteredMoves[index];
                          final capitalizedName = context.translateMove(move.name);

                          final learnDetail = switch (move.learnMethod) {
                            'level-up' => 'Lvl ${move.levelLearnedAt}',
                            'machine' => 'MT',
                            'tutor' => 'Tutor',
                            'egg' => 'Uovo',
                            _ => move.learnMethod,
                          };

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
        },
      ),
    );
  }
}
