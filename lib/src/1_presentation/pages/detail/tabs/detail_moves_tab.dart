import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/3_domain/entities/learn_method.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_cubit.dart';
import 'package:pokefinder/src/3_domain/helpers/game_version_mappings.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
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
    DetailGameVersionCubit? gameVersionCubit;
    try {
      gameVersionCubit = context.read<DetailGameVersionCubit>();
    } catch (_) {}

    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

    return BlocProvider(
      create: (_) {
        final cubit = DetailMovesCubit(
          moves: pokemon.moves,
          logger: getIt<EnLogger>(),
        );
        final gvState = gameVersionCubit?.state;
        if (gvState != null && !gvState.isAllVersions) {
          final targetGroup = GameVersionMappings.versionGroupFor(
            gvState.selectedVersion,
          );
          cubit.updateSelectedVersionGroup(targetGroup, locale);
        }
        return cubit;
      },
      child: _DetailMovesTabContent(
        textColor: textColor,
        gameVersionCubit: gameVersionCubit,
      ),
    );
  }
}

class _DetailMovesTabContent extends StatelessWidget {
  const _DetailMovesTabContent({
    required this.textColor,
    this.gameVersionCubit,
  });

  final Color textColor;
  final DetailGameVersionCubit? gameVersionCubit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DetailMovesCubit>();
    final gvState = gameVersionCubit != null
        ? context.watch<DetailGameVersionCubit>().state
        : null;
    final isFilteringBySpecificGame = !(gvState?.isAllVersions ?? true);

    Widget content = BlocBuilder<DetailMovesCubit, DetailMovesState>(
      builder: (context, state) {
        final versionGroups = state.versionGroups;
        final methods = state.availableMethods;
        final locale =
            Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

        return Column(
          children: [
            // Only show internal version group dropdown when NOT filtering by a specific game
            if (!isFilteringBySpecificGame && versionGroups.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    context.t().gameSelectorLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              versionGroups.contains(state.selectedVersionGroup)
                              ? state.selectedVersionGroup
                              : versionGroups.firstOrNull,
                          isExpanded: true,
                          isDense: true,
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
                  final label = method == DetailMovesCubit.allMethodsFilter
                      ? context.t().movesFilterAll
                      : switch (LearnMethod.fromApi(method)) {
                          LearnMethod.levelUp => context.t().movesFilterLevelUp,
                          LearnMethod.machine => context.t().movesFilterMachine,
                          LearnMethod.tutor => context.t().movesFilterTutor,
                          LearnMethod.egg => context.t().movesFilterEgg,
                          null => method,
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
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          isFilteringBySpecificGame && state.searchQuery.isEmpty
                              ? context.t().movesUnavailableForVersion
                              : context.t().movesSearchEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: state.filteredMoves.length,
                      itemBuilder: (context, index) {
                        final move = state.filteredMoves[index];
                        final capitalizedName = context.translateMove(
                          move.name,
                        );

                        final learnDetail = switch (LearnMethod.fromApi(
                          move.learnMethod,
                        )) {
                          LearnMethod.levelUp => context.t().moveBadgeLevel(
                            level: move.levelLearnedAt,
                          ),
                          LearnMethod.machine => context.t().movesFilterMachine,
                          LearnMethod.tutor => context.t().moveBadgeTutor,
                          LearnMethod.egg => context.t().movesFilterEgg,
                          null => move.learnMethod,
                        };

                        return SurfaceCard(
                          borderRadius: 12,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            onTap: () {
                              MoveDetailBottomSheet.show(
                                context,
                                move.name,
                                capitalizedName,
                              );
                            },
                            title: Text(
                              capitalizedName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                learnDetail,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
    );

    if (gameVersionCubit != null) {
      content = BlocListener<DetailGameVersionCubit, DetailGameVersionState>(
        listener: (context, gameVersionState) {
          final locale =
              Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
          if (!gameVersionState.isAllVersions) {
            final targetGroup = GameVersionMappings.versionGroupFor(
              gameVersionState.selectedVersion,
            );
            cubit.updateSelectedVersionGroup(targetGroup, locale);
          } else {
            final defaultGroup =
                cubit.state.versionGroups.contains('diamond-pearl')
                ? 'diamond-pearl'
                : cubit.state.versionGroups.firstOrNull;
            if (defaultGroup != null) {
              cubit.updateSelectedVersionGroup(defaultGroup, locale);
            }
          }
        },
        child: content,
      );
    }

    return content;
  }
}
