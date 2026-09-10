import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.selectedFormName,
    required this.pokemonId,
    required this.typeImage1,
    required this.typeImage2,
    required this.textColor,
    required this.spriteWidget,
    this.type1,
    this.type2,
    this.showShiny = false,
    this.isLandscape = false,
  });

  final String selectedFormName;
  final int pokemonId;
  final String typeImage1;
  final String typeImage2;
  final Color textColor;
  final PokemonType? type1;
  final PokemonType? type2;
  final bool showShiny;
  final bool isLandscape;

  /// The pre-built sprite widget (including shiny cross-fade logic) injected by
  /// the parent so this widget stays free of state management concerns.
  final Widget spriteWidget;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final displayFormName = formatFormName(context, selectedFormName);
    final shinyLabel = showShiny ? t.formSelectorShiny : t.defaultForm;

    final typeChips = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (type1 != null)
          TypeChip(type: type1!, imageUrl: typeImage1)
        else if (typeImage1.isNotEmpty)
          TypeImage(type: typeImage1),
        if (type2 != null)
          TypeChip(type: type2!, imageUrl: typeImage2)
        else if (typeImage2.isNotEmpty)
          TypeImage(type: typeImage2),
      ],
    );

    final accessibleSprite = Semantics(
      image: true,
      excludeSemantics: true,
      label: '$displayFormName, $shinyLabel',
      child: spriteWidget,
    );

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              excludeSemantics: true,
              label:
                  '$displayFormName, #${pokemonId.toString().padLeft(3, '0')}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayFormName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '#${pokemonId.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(width: 120, height: 120, child: accessibleSprite),
            const SizedBox(height: 8),
            typeChips,
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final spriteDimension = screenWidth < 360 ? 120.0 : 160.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Number (full width, same style)
          Semantics(
            header: true,
            excludeSemantics: true,
            label: '$displayFormName, #${pokemonId.toString().padLeft(3, '0')}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayFormName,
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 28 : 36,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '#${pokemonId.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 28 : 36,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Row 2: Type badges (left) + Sprite (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badges on the left
              Expanded(child: typeChips),
              const SizedBox(width: 8),
              // Sprite on the right
              SizedBox(
                width: spriteDimension,
                height: spriteDimension,
                child: accessibleSprite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
