import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_chip.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Height of a form card that does not depend on the text scale: the 56 dp
/// sprite box, the card's own vertical padding and border, and the three
/// 4-6 dp gaps between the sprite, the name, the type badges and the
/// "current form" badge.
const double _kCardFixedHeight = 90;

/// Height of the text-dependent part of a form card at a 1.0 text scale: a
/// two-line name, up to two lines of type badges, and the "current form" badge.
const double _kCardScaledHeight = 90;

/// Largest text scale the card grows for. Beyond this the strip would eat the
/// screen, and a truncated card is better than a scrollable one.
const double _kMaxCardTextScale = 2.0;

/// Widget displaying a horizontal gallery of alternate forms for a Pokémon.
///
/// Renders nothing when the Pokémon has at most one form. Tapping any form card
/// dispatches [SelectPokemonFormEvent] to the active [PokemonDetailBloc].
class AlternateFormsWidget extends StatelessWidget {
  const AlternateFormsWidget({
    super.key,
    required this.pokemon,
    required this.typeColor,
    required this.textColor,
    this.selectedFormName,
  });

  final Pokemon pokemon;
  final Color typeColor;
  final Color textColor;
  final String? selectedFormName;

  @override
  Widget build(BuildContext context) {
    if (pokemon.forms.length <= 1) {
      return const SizedBox.shrink();
    }

    final activeFormName = selectedFormName ?? pokemon.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(context.t().alternateForms),
        SizedBox(
          // The card holds a sprite plus three pieces of text, so a fixed
          // height overflows at large text scales. Grow it with the scale
          // instead of clipping the name or the badges.
          height:
              _kCardFixedHeight +
              _kCardScaledHeight *
                  MediaQuery.textScalerOf(
                    context,
                  ).scale(1).clamp(1.0, _kMaxCardTextScale),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: pokemon.forms.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final form = pokemon.forms[index];
              final isSelected =
                  form.name.toLowerCase() == activeFormName.toLowerCase();
              final displayFormName = formatFormName(context, form.name);

              return _AlternateFormCard(
                form: form,
                displayName: displayFormName,
                isSelected: isSelected,
                isBasePokemon:
                    form.name.toLowerCase() == pokemon.name.toLowerCase(),
                baseArtworkUrl:
                    pokemon.sprites.artworkDefault ?? pokemon.sprite,
                typeColor: typeColor,
                textColor: textColor,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlternateFormCard extends StatelessWidget {
  const _AlternateFormCard({
    required this.form,
    required this.displayName,
    required this.isSelected,
    required this.isBasePokemon,
    required this.baseArtworkUrl,
    required this.typeColor,
    required this.textColor,
  });

  final PokemonForm form;
  final String displayName;
  final bool isSelected;
  final bool isBasePokemon;
  final String baseArtworkUrl;
  final Color typeColor;
  final Color textColor;

  String _resolveSpriteUrl() {
    if (isBasePokemon) {
      return baseArtworkUrl;
    }
    final formId = PokeApiUrlHelper.extractId(form.url);
    if (formId > 0) {
      return PokeApiUrlHelper.officialArtworkUrl(formId);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final spriteUrl = _resolveSpriteUrl();
    final formId = PokeApiUrlHelper.extractId(form.url);

    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected
          ? '$displayName, ${context.t().currentForm}'
          : displayName,
      child: InkWell(
        onTap: () {
          final bloc = context.read<PokemonDetailBloc>();
          final state = bloc.state;
          if (state is PokemonDetailSuccess) {
            if (!isSelected || state.isLoadingForm) {
              bloc.add(SelectPokemonFormEvent(form));
            }
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? typeColor.withValues(alpha: 0.15)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? typeColor : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: spriteUrl.isNotEmpty
                    ? Image.network(
                        spriteUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          if (formId > 0) {
                            return Image.network(
                              PokeApiUrlHelper.spriteUrl(formId),
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Icon(
                                Icons.catching_pokemon,
                                size: 36,
                                color: textColor.withValues(alpha: 0.4),
                              ),
                            );
                          }
                          return Icon(
                            Icons.catching_pokemon,
                            size: 36,
                            color: textColor.withValues(alpha: 0.4),
                          );
                        },
                      )
                    : Icon(
                        Icons.catching_pokemon,
                        size: 36,
                        color: textColor.withValues(alpha: 0.4),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? typeColor : textColor,
                  height: 1.2,
                ),
              ),
              if (form.type1 != null) ...[
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    TypeChip(type: form.type1!, compact: true),
                    if (form.type2 != null)
                      TypeChip(type: form.type2!, compact: true),
                  ],
                ),
              ],
              if (isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.t().currentForm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
