import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/contrasting_text_color.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_color_scheme.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Widget displaying a horizontal gallery of alternate forms for a Pokémon.
///
/// Renders nothing when the Pokémon has at most one form. Tapping any form card
/// dispatches [SelectPokemonFormEvent] to the active [PokemonBloc].
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
        Text(
          context.t().alternateForms,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 168,
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
                    pokemon.officialArtworkDefault ?? pokemon.sprite,
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
          if (!isSelected) {
            final bloc = context.read<PokemonBloc>();
            final state = bloc.state;
            if (state is PokemonBlocSuccess && !state.isLoadingForm) {
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
                style: TextStyle(
                  fontSize: 11,
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
                    _FormTypeChip(type: form.type1!),
                    if (form.type2 != null) _FormTypeChip(type: form.type2!),
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
                    style: TextStyle(
                      fontSize: 9,
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

class _FormTypeChip extends StatelessWidget {
  const _FormTypeChip({required this.type});

  final PokemonType type;

  @override
  Widget build(BuildContext context) {
    final typeName = context.translateType(type.apiName);
    final color = TypeColorScheme.getColorFromType(type);
    final textColor = contrastingTextColor(color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        typeName,
        style: TextStyle(
          color: textColor,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
