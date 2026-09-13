import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
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
        title: Text(
          t.favorites,
          style: const TextStyle(color: AppPalette.onBrandRed),
        ),
        backgroundColor: AppPalette.brandRed,
        iconTheme: const IconThemeData(color: AppPalette.onBrandRed),
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
          ? _buildEmptyState(context, t)
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
                      key: ValueKey(item.id),
                      entry: item.toIndexEntry(),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations t) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/sad_azurill.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: AppPalette.brandRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.favoritesEmptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.favoritesEmptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/pokedex'),
              icon: const Icon(Icons.catching_pokemon),
              label: Text(t.browsePokedex),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.brandRed,
                foregroundColor: AppPalette.onBrandRed,
                minimumSize: const Size(160, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
