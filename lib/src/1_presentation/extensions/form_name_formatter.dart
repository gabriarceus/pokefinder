import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
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
  final translatedModifier = context.translateTypeOrNull(modifier);

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
