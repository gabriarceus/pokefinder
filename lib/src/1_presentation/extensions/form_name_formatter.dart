import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
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
  final translatedModifier = context.translateTypeOrNull(modifier);

  if (translatedModifier != null) {
    // The modifier is a known Pokémon type; the connective wording (e.g. the
    // Italian "Tipo" prefix) comes from the localized [formTypeModifier].
    return '$baseName - ${context.t().formTypeModifier(type: translatedModifier)}';
  }

  final formattedModifier = modifier.toDisplayCase();
  return '$baseName - $formattedModifier';
}
