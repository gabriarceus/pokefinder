import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_color_scheme.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';

/// Interactive card component displaying a Pokémon index entry summary.
class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.entry, this.onTap});

  final PokemonIndexEntry entry;
  final VoidCallback? onTap;

  static Color _resolveFormBadgeColor(
    PokemonFormCategory category,
    ThemeData theme,
  ) {
    return switch (category) {
      PokemonFormCategory.mega => Colors.purple.shade100,
      PokemonFormCategory.primal => Colors.indigo.shade100,
      PokemonFormCategory.regional => Colors.teal.shade100,
      PokemonFormCategory.gmax => Colors.deepOrange.shade100,
      PokemonFormCategory.battleMode => Colors.blueGrey.shade100,
      PokemonFormCategory.cosmetic => Colors.amber.shade100,
      PokemonFormCategory.canonical =>
        theme.colorScheme.surfaceContainerHighest,
    };
  }

  static Color _resolveFormBadgeTextColor(
    PokemonFormCategory category,
    ThemeData theme,
  ) {
    return switch (category) {
      PokemonFormCategory.mega => Colors.purple.shade900,
      PokemonFormCategory.primal => Colors.indigo.shade900,
      PokemonFormCategory.regional => Colors.teal.shade900,
      PokemonFormCategory.gmax => Colors.deepOrange.shade900,
      PokemonFormCategory.battleMode => Colors.blueGrey.shade900,
      PokemonFormCategory.cosmetic => Colors.amber.shade900,
      PokemonFormCategory.canonical => theme.colorScheme.onSurfaceVariant,
    };
  }

  static String _resolveBaseCardIndicator(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final displayName = context.translatePokemonIndexEntry(entry);
    final primaryType = entry.types.isNotEmpty ? entry.types.first : null;
    final accentColor = primaryType != null
        ? TypeColorScheme.getColorFromType(primaryType)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.5);

    final idDisplay = entry.isAlternateForm
        ? entry.dexNumberDisplay
        : entry.formattedId;
    final genNumber = entry.generation > 0
        ? entry.generation
        : entry.effectiveSpeciesGeneration;

    final typeNames = entry.types
        .map((t) => context.translateTypeOrNull(t.apiName) ?? t.name)
        .join(', ');
    final formTag = entry.isAlternateForm && entry.formBadgeText != null
        ? ', ${entry.formBadgeText}'
        : (!entry.isAlternateForm && entry.hasAlternateForms)
        ? ', ${l10n.hasAlternateFormsSemantics}'
        : '';
    final fullLabel = typeNames.isEmpty
        ? '$idDisplay, $displayName$formTag'
        : '$idDisplay, $displayName$formTag, $typeNames';

    return Semantics(
      button: true,
      label: fullLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push('/pokemon/${entry.name}'),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle type color watermark in corner
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            idDisplay,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (entry.isAlternateForm &&
                              entry.formBadgeText != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _resolveFormBadgeColor(
                                    entry.formCategory,
                                    theme,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.formBadgeText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _resolveFormBadgeTextColor(
                                      entry.formCategory,
                                      theme,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else if (!entry.isAlternateForm &&
                              entry.hasAlternateForms)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _resolveBaseCardIndicator(l10n, entry),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          else if (genNumber > 0)
                            Text(
                              'Gen $genNumber',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.outline,
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
                      const SizedBox(height: 8),
                      Expanded(
                        child: Center(
                          child: Image.network(
                            entry.spriteUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.catching_pokemon,
                                size: 48,
                                color: theme.colorScheme.outlineVariant,
                              );
                            },
                          ),
                        ),
                      ),
                      if (entry.types.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: entry.types.map((type) {
                            final typeColor = TypeColorScheme.getColorFromType(
                              type,
                            );
                            final localizedName =
                                context.translateTypeOrNull(type.apiName) ??
                                type.name;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: typeColor.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                localizedName,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
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
