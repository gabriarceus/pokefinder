import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
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

/// Browsable, paginated Pokédex discovery view with search, filtering, and responsive layout.
class PokedexBrowsePage extends StatefulWidget {
  const PokedexBrowsePage({super.key});

  @override
  State<PokedexBrowsePage> createState() => _PokedexBrowsePageState();
}

class _PokedexBrowsePageState extends State<PokedexBrowsePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll - 300) {
      context.read<PokedexBloc>().add(const PokedexLoadMoreEvent());
    }
  }

  void _onBlocListener(BuildContext context, PokedexState state) {
    if (_searchController.text != state.searchQuery) {
      _searchController.text = state.searchQuery;
    }

    final randomPokemon = state.randomPokemonToNavigate;
    if (randomPokemon != null) {
      context.read<PokedexBloc>().add(const PokedexRandomNavigationDoneEvent());
      context.push('/pokemon/${randomPokemon.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<PokedexBloc, PokedexState>(
      listener: _onBlocListener,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            t.pokedexTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppPalette.brandRed,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            BlocBuilder<ComparisonCubit, ComparisonState>(
              buildWhen: (previous, current) =>
                  previous.entries.length != current.entries.length,
              builder: (context, comparison) {
                final count = comparison.entries.length;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: t.compareTitle,
                      icon: const Icon(Icons.compare_arrows_rounded),
                      onPressed: () => context.push('/compare'),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              tooltip: t.randomPokemon,
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () {
                context.read<PokedexBloc>().add(
                  const PokedexSelectRandomPokemonEvent(),
                );
              },
            ),
            BlocBuilder<PokedexBloc, PokedexState>(
              buildWhen: (previous, current) =>
                  previous.activeFilterCount != current.activeFilterCount,
              builder: (context, state) {
                final filterCount = state.activeFilterCount;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: t.filters,
                      icon: const Icon(Icons.filter_list_rounded),
                      onPressed: () => PokedexFilterBottomSheet.show(context),
                    ),
                    if (filterCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              filterCount > 9 ? '9+' : filterCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surface,
              child: BlocBuilder<PokedexBloc, PokedexState>(
                buildWhen: (previous, current) =>
                    previous.searchQuery != current.searchQuery,
                builder: (context, state) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: t.searchPokedexPlaceholder,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.searchQuery.isNotEmpty
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
                    onChanged: (query) {
                      context.read<PokedexBloc>().add(
                        PokedexSearchQueryChangedEvent(query),
                      );
                    },
                  );
                },
              ),
            ),
            // Main Content Area
            Expanded(
              child: BlocBuilder<PokedexBloc, PokedexState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PokedexStatus.initial:
                    case PokedexStatus.loading:
                      return _buildLoadingGrid(context);

                    case PokedexStatus.failure:
                      if (state.allEntries.isEmpty) {
                        return _buildErrorView(context, state);
                      }
                      // Stale-if-error: render cached list with fallback banner
                      return _buildCatalogView(context, state);

                    case PokedexStatus.success:
                      if (state.filteredEntries.isEmpty) {
                        return _buildEmptyFiltersView(context, state);
                      }
                      return _buildCatalogView(context, state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogView(BuildContext context, PokedexState state) {
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
          final crossAxisCount = _resolveCrossAxisCount(constraints.maxWidth);

          return CustomScrollView(
            key: const PageStorageKey('pokedex_browse_scroll_key'),
            controller: _scrollController,
            slivers: [
              if (state.failure != null && state.allEntries.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).offlineIndexNotice,
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = state.visibleEntries[index];
                    return PokemonCard(entry: entry);
                  }, childCount: state.visibleEntries.length),
                ),
              ),
              if (state.hasMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _resolveCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, index) => const PokemonCardSkeleton(),
        );
      },
    );
  }

  Widget _buildEmptyFiltersView(BuildContext context, PokedexState state) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              t.noPokemonFound,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                context.read<PokedexBloc>().add(
                  const PokedexClearFiltersEvent(),
                );
              },
              child: Text(t.clearFilters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, PokedexState state) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final message =
        state.failure?.localizedMessage(context) ?? t.errorUnexpected;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PokedexBloc>().add(const PokedexFetchIndexEvent());
              },
              child: Text(t.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  int _resolveCrossAxisCount(double width) {
    if (width < 340) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }
}
