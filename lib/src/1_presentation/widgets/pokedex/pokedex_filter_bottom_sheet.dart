import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_color_scheme.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokedex_sort_order.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Modal bottom sheet allowing users to filter by types, generation, and sort order.
class PokedexFilterBottomSheet extends StatelessWidget {
  const PokedexFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PokedexBloc>(),
        child: const PokedexFilterBottomSheet(),
      ),
    );
  }

  static const List<PokemonType> _standardTypes = [
    PokemonType.normal,
    PokemonType.fire,
    PokemonType.water,
    PokemonType.grass,
    PokemonType.electric,
    PokemonType.ice,
    PokemonType.fighting,
    PokemonType.poison,
    PokemonType.ground,
    PokemonType.flying,
    PokemonType.psychic,
    PokemonType.bug,
    PokemonType.rock,
    PokemonType.ghost,
    PokemonType.dragon,
    PokemonType.dark,
    PokemonType.steel,
    PokemonType.fairy,
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<PokedexBloc, PokedexState>(
          builder: (context, state) {
            return Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        t.filters,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.activeFilterCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.activeFilterCount.toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      TextButton(
                        onPressed: state.hasActiveFilters
                            ? () => context.read<PokedexBloc>().add(
                                const PokedexClearFiltersEvent(),
                              )
                            : null,
                        child: Text(t.reset),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Types Section
                      Text(
                        t.types,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _standardTypes.map((type) {
                          final isSelected = state.selectedTypes.contains(type);
                          final typeColor = TypeColorScheme.getColorFromType(
                            type,
                          );
                          final label =
                              context.translateTypeOrNull(type.apiName) ??
                              type.name;

                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: typeColor.withValues(alpha: 0.3),
                            checkmarkColor: typeColor,
                            side: BorderSide(
                              color: isSelected
                                  ? typeColor
                                  : theme.colorScheme.outlineVariant,
                            ),
                            onSelected: (_) {
                              context.read<PokedexBloc>().add(
                                PokedexTypeFilterToggledEvent(type),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Generation Section
                      Text(
                        t.generation,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(t.generationAll),
                            selected: state.selectedGeneration == null,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PokedexBloc>().add(
                                  const PokedexGenerationFilterChangedEvent(
                                    null,
                                  ),
                                );
                              }
                            },
                          ),
                          ...List.generate(9, (index) {
                            final gen = index + 1;
                            return ChoiceChip(
                              label: Text(t.generationNum(number: gen)),
                              selected: state.selectedGeneration == gen,
                              onSelected: (selected) {
                                context.read<PokedexBloc>().add(
                                  PokedexGenerationFilterChangedEvent(
                                    selected ? gen : null,
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sort Section
                      Text(
                        t.sortBy,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(t.sortIdAscending),
                            selected:
                                state.sortOrder == PokedexSortOrder.idAscending,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PokedexBloc>().add(
                                  const PokedexSortOrderChangedEvent(
                                    PokedexSortOrder.idAscending,
                                  ),
                                );
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(t.sortIdDescending),
                            selected:
                                state.sortOrder ==
                                PokedexSortOrder.idDescending,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PokedexBloc>().add(
                                  const PokedexSortOrderChangedEvent(
                                    PokedexSortOrder.idDescending,
                                  ),
                                );
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(t.sortNameAscending),
                            selected:
                                state.sortOrder ==
                                PokedexSortOrder.nameAscending,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PokedexBloc>().add(
                                  const PokedexSortOrderChangedEvent(
                                    PokedexSortOrder.nameAscending,
                                  ),
                                );
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(t.sortNameDescending),
                            selected:
                                state.sortOrder ==
                                PokedexSortOrder.nameDescending,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<PokedexBloc>().add(
                                  const PokedexSortOrderChangedEvent(
                                    PokedexSortOrder.nameDescending,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Bottom apply button
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.apply),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
