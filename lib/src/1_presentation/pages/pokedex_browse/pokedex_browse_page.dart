import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/1_presentation/widgets/empty_state_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokedex_filter_bottom_sheet.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card_skeleton.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';

/// Scope provider that ensures the [PokedexBloc] instance survives detail navigation
/// so scroll position and filter state remain intact.
class PokedexBrowsePageProvider extends StatelessWidget {
  const PokedexBrowsePageProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => createPokedexBloc(), child: child);
  }
}

/// Browsable Pokédex discovery view with search, filtering, and responsive layout.
class PokedexBrowsePage extends StatefulWidget {
  const PokedexBrowsePage({super.key});

  @override
  State<PokedexBrowsePage> createState() => _PokedexBrowsePageState();
}

class _PokedexBrowsePageState extends State<PokedexBrowsePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRandomPokemon(BuildContext context, PokedexState state) {
    context.read<PokedexBloc>().add(const PokedexRandomNavigationDoneEvent());
    context.push(AppRoutes.pokemon(state.randomPokemonToNavigate!.name));
  }

  void _onTypeFilterFailure(BuildContext context, PokedexState state) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.typeFilterFailure!.localizedMessage(context)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<PokedexBloc, PokedexState>(
          listenWhen: (previous, current) =>
              previous.filters.query != current.filters.query &&
              _searchController.text != current.filters.query,
          listener: (context, state) =>
              _searchController.text = state.filters.query,
        ),
        BlocListener<PokedexBloc, PokedexState>(
          listenWhen: (previous, current) =>
              current.randomPokemonToNavigate != null &&
              previous.randomPokemonToNavigate !=
                  current.randomPokemonToNavigate,
          listener: _onRandomPokemon,
        ),
        BlocListener<PokedexBloc, PokedexState>(
          listenWhen: (previous, current) =>
              current.typeFilterFailure != null &&
              previous.typeFilterFailure != current.typeFilterFailure,
          listener: _onTypeFilterFailure,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.pokedexTitle),
          actions: [
            BlocSelector<ComparisonCubit, ComparisonState, int>(
              selector: (state) => state.entries.length,
              builder: (context, count) => IconButton(
                tooltip: t.compareTitle,
                icon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.compare_arrows_rounded),
                ),
                onPressed: () => context.push(AppRoutes.compare),
              ),
            ),
            IconButton(
              tooltip: t.randomPokemon,
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () => context.read<PokedexBloc>().add(
                const PokedexSelectRandomPokemonEvent(),
              ),
            ),
            BlocSelector<PokedexBloc, PokedexState, int>(
              selector: (state) => state.filters.activeFilterCount,
              builder: (context, count) => IconButton(
                tooltip: t.filters,
                icon: Badge.count(
                  count: count,
                  maxCount: 9,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.filter_list_rounded),
                ),
                onPressed: () => PokedexFilterBottomSheet.show(context),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: BlocSelector<PokedexBloc, PokedexState, String>(
                selector: (state) => state.filters.query,
                builder: (context, query) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: t.searchPokedexPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<PokedexBloc>().add(
                                  const PokedexSearchQueryChangedEvent(''),
                                );
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (query) => context.read<PokedexBloc>().add(
                      PokedexSearchQueryChangedEvent(query),
                    ),
                  );
                },
              ),
            ),
            BlocSelector<PokedexBloc, PokedexState, bool>(
              selector: (state) => state.loadingTypes.isNotEmpty,
              builder: (context, isLoadingTypes) => isLoadingTypes
                  ? const LinearProgressIndicator()
                  : const SizedBox(height: 4),
            ),
            Expanded(
              child: BlocBuilder<PokedexBloc, PokedexState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PokedexStatus.initial:
                    case PokedexStatus.loading:
                      return const _LoadingGrid();

                    case PokedexStatus.failure:
                      return EmptyStateView(
                        icon: Icons.error_outline_rounded,
                        isError: true,
                        title:
                            state.failure?.localizedMessage(context) ??
                            t.errorUnexpected,
                        action: FilledButton(
                          onPressed: () => context.read<PokedexBloc>().add(
                            const PokedexFetchIndexEvent(),
                          ),
                          child: Text(t.retryButton),
                        ),
                      );

                    case PokedexStatus.success:
                      if (state.filteredEntries.isEmpty &&
                          state.loadingTypes.isEmpty) {
                        return EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: t.noPokemonFound,
                          action: FilledButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<PokedexBloc>().add(
                                const PokedexClearFiltersEvent(),
                              );
                            },
                            child: Text(t.clearFilters),
                          ),
                        );
                      }
                      return _CatalogView(state: state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _crossAxisCount(double width) {
  if (width < 340) return 1;
  if (width < 600) return 2;
  if (width < 900) return 3;
  if (width < 1200) return 4;
  return 5;
}

SliverGridDelegate _gridDelegate(double width) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: _crossAxisCount(width),
    childAspectRatio: 0.85,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );
}

class _CatalogView extends StatelessWidget {
  const _CatalogView({required this.state});

  final PokedexState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<PokedexBloc>();
        bloc.add(const PokedexFetchIndexEvent(forceRefresh: true));
        // Await next emission to dismiss the refresh indicator smoothly
        await bloc.stream.firstWhere(
          (s) => !s.isRefreshing,
          orElse: () => bloc.state,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            key: const PageStorageKey('pokedex_browse_scroll_key'),
            slivers: [
              if (state.failure != null)
                SliverToBoxAdapter(
                  child: Container(
                    color: colorScheme.tertiaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: colorScheme.onTertiaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).offlineIndexNotice,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid.builder(
                  gridDelegate: _gridDelegate(constraints.maxWidth),
                  itemCount: state.filteredEntries.length,
                  itemBuilder: (context, index) =>
                      PokemonCard(entry: state.filteredEntries[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _gridDelegate(constraints.maxWidth),
          itemCount: 12,
          itemBuilder: (context, index) => const PokemonCardSkeleton(),
        );
      },
    );
  }
}
