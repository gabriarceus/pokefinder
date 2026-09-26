import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/contrasting_text_color.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_color_scheme.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// A chip showing the localized name of a Pokémon [type] in its type color.
///
/// With [onSelected], the chip is a toggle: filled when [selected], outlined
/// otherwise, with the same size in both states.
class TypeChip extends StatelessWidget {
  const TypeChip({
    super.key,
    required this.type,
    this.compact = false,
    this.selected = true,
    this.onSelected,
  });

  final PokemonType type;

  /// Uses a smaller padding and label.
  final bool compact;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = context.translateType(type.apiName);
    final typeColor = TypeColorScheme.getColorFromType(type);
    final labelStyle =
        (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color: selected
                  ? contrastingTextColor(typeColor)
                  : theme.colorScheme.onSurface,
            );

    final onSelected = this.onSelected;
    if (onSelected != null) {
      return FilterChip(
        label: Text(label),
        labelStyle: labelStyle,
        selected: selected,
        showCheckmark: false,
        selectedColor: typeColor,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: typeColor, width: 1.5),
        onSelected: onSelected,
      );
    }

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: labelStyle),
      ),
    );
  }
}
