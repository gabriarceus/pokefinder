import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_chip.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Modal bottom sheet allowing users to filter by types, generation, and sort order.
///
/// Filters apply at once; the bottom button closes the sheet.
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
    final bloc = context.read<PokedexBloc>();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<PokedexBloc, PokedexState>(
          builder: (context, state) {
            final filters = state.filters;
            final formFilters = [
              (PokedexFormFilter.canonicalOnly, t.formFilterCanonicalOnly),
              (PokedexFormFilter.all, t.formFilterAll),
              (PokedexFormFilter.mega, t.formFilterMega),
              (PokedexFormFilter.regional, t.formFilterRegional),
              (PokedexFormFilter.gmax, t.formFilterGmax),
            ];
            final sortOrders = [
              (PokedexSortOrder.idAscending, t.sortIdAscending),
              (PokedexSortOrder.idDescending, t.sortIdDescending),
              (PokedexSortOrder.nameAscending, t.sortNameAscending),
              (PokedexSortOrder.nameDescending, t.sortNameDescending),
            ];

            return Column(
              children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Badge.count(
                        count: filters.activeFilterCount,
                        isLabelVisible: filters.activeFilterCount > 0,
                        offset: const Offset(16, -4),
                        child: Text(
                          t.filters,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: filters.hasActiveFilters
                            ? () => bloc.add(const PokedexClearFiltersEvent())
                            : null,
                        child: Text(t.reset),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      SectionTitle(t.forms),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (formFilter, label) in formFilters)
                            ChoiceChip(
                              label: Text(label),
                              selected: filters.formFilter == formFilter,
                              onSelected: (selected) {
                                if (selected) {
                                  bloc.add(
                                    PokedexFormFilterChangedEvent(formFilter),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.includeCosmeticForms),
                        value: filters.includeCosmeticForms,
                        onChanged: (value) =>
                            bloc.add(PokedexCosmeticToggleChangedEvent(value)),
                      ),
                      const SizedBox(height: 16),
                      SectionTitle(t.types),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final type in _standardTypes)
                            TypeChip(
                              type: type,
                              selected: filters.selectedTypes.contains(type),
                              onSelected: (_) =>
                                  bloc.add(PokedexTypeFilterToggledEvent(type)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionTitle(t.generation),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(t.generationAll),
                            selected: filters.generation == null,
                            onSelected: (selected) {
                              if (selected) {
                                bloc.add(
                                  const PokedexGenerationFilterChangedEvent(
                                    null,
                                  ),
                                );
                              }
                            },
                          ),
                          for (var gen = 1; gen <= 9; gen++)
                            ChoiceChip(
                              label: Text(t.generationNum(number: gen)),
                              selected: filters.generation == gen,
                              onSelected: (selected) => bloc.add(
                                PokedexGenerationFilterChangedEvent(
                                  selected ? gen : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionTitle(t.sortBy),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (sortOrder, label) in sortOrders)
                            ChoiceChip(
                              label: Text(label),
                              selected: filters.sortOrder == sortOrder,
                              onSelected: (selected) {
                                if (selected) {
                                  bloc.add(
                                    PokedexSortOrderChangedEvent(sortOrder),
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          t.showResults(count: state.filteredEntries.length),
                        ),
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
