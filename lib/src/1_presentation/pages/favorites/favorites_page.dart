import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/empty_state_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/2_application/bloc/favorites_cubit/favorites_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Screen displaying user-favorited Pokémon with sorting and empty state support.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final favoritesState = context.watch<FavoritesCubit>().state;
    final sortedList = favoritesState.sortedFavorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.favorites),
        actions: [
          if (sortedList.isNotEmpty)
            PopupMenuButton<FavoriteSortOrder>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: t.sortBy,
              initialValue: favoritesState.sortOrder,
              onSelected: (order) {
                context.read<FavoritesCubit>().setSortOrder(order);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: FavoriteSortOrder.idAscending,
                  child: Text(t.sortIdAscending),
                ),
                PopupMenuItem(
                  value: FavoriteSortOrder.idDescending,
                  child: Text(t.sortIdDescending),
                ),
                PopupMenuItem(
                  value: FavoriteSortOrder.nameAscending,
                  child: Text(t.sortNameAscending),
                ),
                PopupMenuItem(
                  value: FavoriteSortOrder.nameDescending,
                  child: Text(t.sortNameDescending),
                ),
                PopupMenuItem(
                  value: FavoriteSortOrder.recentlyAdded,
                  child: Text(t.sortRecentlyAdded),
                ),
              ],
            ),
        ],
      ),
      body: sortedList.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: t.favoritesEmptyTitle,
              message: t.favoritesEmptyMessage,
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.pokedex),
                icon: const Icon(Icons.catching_pokemon),
                label: Text(t.browsePokedex),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 180)
                    .floor()
                    .clamp(2, 6);

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: sortedList.length,
                  itemBuilder: (context, index) {
                    final item = sortedList[index];
                    return PokemonCard(
                      key: ValueKey(item.pokemon.id),
                      entry: item.pokemon.toIndexEntry(),
                    );
                  },
                );
              },
            ),
    );
  }
}
