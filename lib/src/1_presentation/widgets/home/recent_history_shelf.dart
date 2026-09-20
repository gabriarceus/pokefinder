import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/2_application/bloc/recent_history_cubit/recent_history_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Quick-access horizontal shelf for recently viewed Pokémon and search queries.
class RecentHistoryShelf extends StatelessWidget {
  const RecentHistoryShelf({super.key, required this.onSelectQuery});

  final ValueChanged<String> onSelectQuery;

  @override
  Widget build(BuildContext context) {
    RecentHistoryState historyState = const RecentHistoryState();
    try {
      historyState = context.watch<RecentHistoryCubit>().state;
    } catch (_) {}

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
                  child: Text(
                    t.clear,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
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
                  child: Text(
                    t.clear,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 130,
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
    final displayName = item.name.capitalize();

    return Semantics(
      button: true,
      label: displayName,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/pokemon/${item.name}'),
          child: Ink(
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Semantics(
                    button: true,
                    label:
                        '${AppLocalizations.of(context).removeFromHistory}: $displayName',
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton(
                        iconSize: 14,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        icon: Icon(
                          Icons.close,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        onPressed: () {
                          context
                              .read<RecentHistoryCubit>()
                              .removeRecentPokemon(item.id);
                        },
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '#${item.id.toString().padLeft(3, '0')}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Center(
                        child: item.spriteUrl.isNotEmpty
                            ? Image.network(
                                item.spriteUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.catching_pokemon,
                                  size: 32,
                                  color: AppPalette.brandRed,
                                ),
                              )
                            : const Icon(
                                Icons.catching_pokemon,
                                size: 32,
                                color: AppPalette.brandRed,
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
