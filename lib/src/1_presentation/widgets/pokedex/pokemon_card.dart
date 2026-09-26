import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/add_to_team_sheet.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_chip.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/favorites_cubit/favorites_cubit.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';

/// Side of the square that holds the card image.
const _kImageSize = 96.0;

/// Card of a Pokémon index entry: number, name, image, types and a favorite
/// toggle.
///
/// A tap opens the detail; a long press opens the compare and team actions.
class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.entry});

  final PokemonIndexEntry entry;

  static String _baseCardIndicator(
    AppLocalizations l10n,
    PokemonIndexEntry entry,
  ) {
    if (entry.availableFormCategories.contains(PokemonFormCategory.mega)) {
      return l10n.formBadgeMegaIndicator;
    }
    if (entry.availableFormCategories.contains(PokemonFormCategory.regional)) {
      return l10n.formBadgeRegionalIndicator;
    }
    if (entry.availableFormCategories.contains(PokemonFormCategory.gmax)) {
      return l10n.formBadgeGmaxIndicator;
    }
    return l10n.formBadgeFormsIndicator;
  }

  void _toggleComparison(BuildContext context) {
    final cubit = context.read<ComparisonCubit>();
    final wasSelected = cubit.isSelected(entry.id);
    final nowSelected = cubit.toggleEntry(entry.summary);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (nowSelected) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.compareAdded),
          action: SnackBarAction(
            label: l10n.compareView,
            onPressed: () => context.push(AppRoutes.compare),
          ),
        ),
      );
    } else if (!wasSelected) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.compareFull)));
    }
  }

  void _showActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isComparing = context.read<ComparisonCubit>().isSelected(entry.id);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.compare_arrows_rounded),
              title: Text(isComparing ? l10n.compareRemove : l10n.compareAdd),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _toggleComparison(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_rounded),
              title: Text(l10n.teamAddMember),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showAddToTeamSheet(context, entry.summary);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(entry.id),
    );
    final displayName = context.translatePokemonIndexEntry(entry);
    final idDisplay = entry.isAlternateForm
        ? entry.dexNumberDisplay
        : entry.formattedId;
    final genNumber = entry.generation > 0
        ? entry.generation
        : entry.effectiveSpeciesGeneration;

    final typeNames = entry.types
        .map((t) => context.translateType(t.apiName))
        .join(', ');
    final formTag = entry.isAlternateForm && entry.formBadgeText != null
        ? ', ${entry.formBadgeText}'
        : (!entry.isAlternateForm && entry.hasAlternateForms)
        ? ', ${l10n.hasAlternateFormsSemantics}'
        : '';
    final fullLabel = typeNames.isEmpty
        ? '$idDisplay, $displayName$formTag'
        : '$idDisplay, $displayName$formTag, $typeNames';

    final (
      String? badgeText,
      Color badgeColor,
      Color badgeTextColor,
    ) = switch (entry) {
      PokemonIndexEntry(isAlternateForm: true, :final formBadgeText?) => (
        formBadgeText,
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.onTertiaryContainer,
      ),
      PokemonIndexEntry(isAlternateForm: false, hasAlternateForms: true) => (
        _baseCardIndicator(l10n, entry),
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
      _ => (
        genNumber > 0 ? l10n.generationNum(number: genNumber) : null,
        Colors.transparent,
        theme.colorScheme.outline,
      ),
    };

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Semantics(
            button: true,
            label: fullLabel,
            excludeSemantics: true,
            child: InkWell(
              onTap: () => context.push(AppRoutes.pokemon(entry.name)),
              onLongPress: () => _showActions(context),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            idDisplay,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badgeText != null)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: badgeTextColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Image.network(
                          entry.customSpriteUrl ?? entry.officialArtworkUrl,
                          width: _kImageSize,
                          height: _kImageSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    // Leaves room for the favorite button.
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: SizedBox(
                        height: 24,
                        child: Wrap(
                          spacing: 4,
                          children: [
                            for (final type in entry.types)
                              TypeChip(type: type, compact: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              tooltip: isFavorite
                  ? l10n.removeFromFavorites
                  : l10n.addToFavorites,
              onPressed: () =>
                  context.read<FavoritesCubit>().toggleFavorite(entry.summary),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
