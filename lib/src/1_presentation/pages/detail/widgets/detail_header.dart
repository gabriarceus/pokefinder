import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Height of the name and number row.
const _kNameRowHeight = 44.0;

/// Name, number, type chips and sprite of the displayed Pokémon form.
///
/// The sprite fills the height left below the name row, up to 160 dp.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.selectedFormName,
    required this.pokemonId,
    required this.textColor,
    required this.spriteDefault,
    required this.spriteShiny,
    this.type1,
    this.type2,
    this.showShiny = false,
  });

  final String selectedFormName;
  final int pokemonId;
  final Color textColor;
  final String spriteDefault;
  final String spriteShiny;
  final PokemonType? type1;
  final PokemonType? type2;
  final bool showShiny;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final displayFormName = formatFormName(context, selectedFormName);
    final shinyLabel = showShiny ? t.formSelectorShiny : t.defaultForm;
    final number = '#${pokemonId.toString().padLeft(3, '0')}';
    final types = [type1, type2].whereType<PokemonType>().toList();
    final nameStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: textColor,
    );

    // Tapping either chip presets the calculator with this Pokémon's full
    // 1–2 defending types, so the defensive profile stays intact.
    Widget tappableChip(PokemonType type) {
      final typeName = context.translateType(type.apiName);
      return Semantics(
        button: true,
        label: '$typeName, ${t.matchupViewMatchups}',
        excludeSemantics: true,
        child: Tooltip(
          message: t.matchupViewMatchups,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(AppRoutes.matchups(types)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TypeChip(type: type),
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // No lower bound: the header lives in a `FlexibleSpaceBar` background,
        // so it can be handed less room than the sprite would like (a short
        // landscape screen, a large text scale, or mid-collapse). A hard floor
        // made the column overflow there. The sprite shrinks instead; while the
        // app bar is collapsed the sprite is behind the toolbar anyway.
        final spriteSize = (constraints.maxHeight - _kNameRowHeight - 8).clamp(
          0.0,
          160.0,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _kNameRowHeight,
              child: Semantics(
                header: true,
                excludeSemantics: true,
                label: '$displayFormName, $number',
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(displayFormName, style: nameStyle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(number, style: nameStyle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // One line, scrollable if it does not fit: a `Wrap` grew to two
                // lines at a 2.0 text scale and pushed the header past the
                // height the collapsing app bar gives it.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [for (final type in types) tappableChip(type)],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  image: true,
                  excludeSemantics: true,
                  label: '$displayFormName, $shinyLabel',
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: showShiny
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: SpriteBoxImage(
                      sprite: spriteDefault,
                      size: spriteSize,
                    ),
                    secondChild: SpriteBoxImage(
                      sprite: spriteShiny,
                      size: spriteSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
