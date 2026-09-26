import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/2_application/bloc/recent_history_cubit/recent_history_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Quick-access horizontal shelf for recently viewed Pokémon and search queries.
class RecentHistoryShelf extends StatelessWidget {
  const RecentHistoryShelf({super.key, required this.onSelectQuery});

  final ValueChanged<String> onSelectQuery;

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<RecentHistoryCubit>().state;

    if (!historyState.isHistoryEnabled) return const SizedBox.shrink();

    final hasPokemon = historyState.recentPokemon.isNotEmpty;
    final hasSearches = historyState.recentSearches.isNotEmpty;

    if (!hasPokemon && !hasSearches) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSearches) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t.recentSearches,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<RecentHistoryCubit>().clearRecentSearches();
                  },
                  child: Text(t.clear),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: historyState.recentSearches.map((query) {
                return InputChip(
                  label: Text(query),
                  onPressed: () => onSelectQuery(query),
                  onDeleted: () {
                    context.read<RecentHistoryCubit>().removeRecentSearch(
                      query,
                    );
                  },
                  deleteIcon: const Icon(Icons.close, size: 14),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          if (hasPokemon) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    t.recentlyViewed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<RecentHistoryCubit>().clearRecentPokemon();
                  },
                  child: Text(t.clear),
                ),
              ],
            ),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: historyState.recentPokemon.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = historyState.recentPokemon[index];
                  return _RecentPokemonCard(item: item);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentPokemonCard extends StatelessWidget {
  const _RecentPokemonCard({required this.item});

  final RecentPokemon item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pokemon = item.pokemon;
    final displayName = pokemon.name.capitalize();
    final placeholder = Icon(
      Icons.catching_pokemon,
      size: 32,
      color: theme.colorScheme.primary,
    );

    return Semantics(
      button: true,
      label: displayName,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.push(AppRoutes.pokemon(pokemon.name));
          },
          child: Ink(
            width: 100,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 16,
                      tooltip:
                          '${AppLocalizations.of(context).removeFromHistory}: $displayName',
                      icon: Icon(Icons.close, color: theme.colorScheme.outline),
                      onPressed: () => context
                          .read<RecentHistoryCubit>()
                          .removeRecentPokemon(pokemon.id),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: pokemon.spriteUrl.isNotEmpty
                        ? Image.network(
                            pokemon.spriteUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => placeholder,
                          )
                        : placeholder,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
