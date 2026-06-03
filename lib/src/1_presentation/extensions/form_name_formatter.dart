import 'package:flutter/widgets.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

/// Formats a raw Pokémon form name into a user-friendly display string.
///
/// Handles type-based form modifiers (e.g. "arceus-fire" → "Arceus - Fuoco")
/// and falls back to simple capitalization for unrecognized modifiers.
String formatFormName(BuildContext context, String rawName) {
  if (rawName.isEmpty) return '';
  final parts = rawName.split('-');
  if (parts.length == 1) {
    return parts[0].capitalize();
  }

  // Capitalize base pokemon name
  final baseName = parts[0].capitalize();

  final modifier = parts.skip(1).join('-');
  final t = context.t();

  final translatedModifier = switch (modifier.toLowerCase()) {
    'normal' => t.typeNormal,
    'fire' => t.typeFire,
    'water' => t.typeWater,
    'grass' => t.typeGrass,
    'electric' => t.typeElectric,
    'ice' => t.typeIce,
    'fighting' => t.typeFighting,
    'poison' => t.typePoison,
    'ground' => t.typeGround,
    'flying' => t.typeFlying,
    'psychic' => t.typePsychic,
    'bug' => t.typeBug,
    'rock' => t.typeRock,
    'ghost' => t.typeGhost,
    'dragon' => t.typeDragon,
    'steel' => t.typeSteel,
    'fairy' => t.typeFairy,
    'dark' => t.typeDark,
    'stellar' => t.typeStellar,
    'shadow' => t.typeShadow,
    'unknown' => t.typeUnknown,
    _ => null,
  };

  if (translatedModifier != null) {
    // When the modifier is a known Pokémon type, prefix with "Tipo" in Italian
    // to match the conventional form naming (e.g. "Arceus - Tipo Fuoco").
    final localeName = Localizations.localeOf(context).languageCode;
    if (localeName == 'it') {
      return '$baseName - Tipo $translatedModifier';
    }
    return '$baseName - $translatedModifier';
  }

  final formattedModifier = modifier.toDisplayCase();
  return '$baseName - $formattedModifier';
}
