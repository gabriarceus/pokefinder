import 'package:pokefinder/l10n/app_localizations.dart';

/// Matches blank or punctuation/dash-only placeholders (e.g. `-`, `—`).
final placeholderOnlyRegex = RegExp(r'^[\p{Pd}\p{Po}\s]+$', unicode: true);

/// Returns [translation] unless it is blank or placeholder-only.
String? usableTranslationOrNull(String? translation) {
  if (translation == null) return null;
  final trimmed = translation.trim();
  if (trimmed.isEmpty) return null;
  if (placeholderOnlyRegex.hasMatch(trimmed)) return null;
  return translation;
}

/// Localized Pokémon type lookup shared by UI translators.
extension AppLocalizationsTypeX on AppLocalizations {
  /// Returns the localized name of [typeName], or null when unrecognized.
  String? translateTypeOrNull(String typeName) {
    final key = typeName.toLowerCase().trim();
    return switch (key) {
      'normal' => typeNormal,
      'fire' => typeFire,
      'water' => typeWater,
      'grass' => typeGrass,
      'electric' => typeElectric,
      'ice' => typeIce,
      'fighting' => typeFighting,
      'poison' => typePoison,
      'ground' => typeGround,
      'flying' => typeFlying,
      'psychic' => typePsychic,
      'bug' => typeBug,
      'rock' => typeRock,
      'ghost' => typeGhost,
      'dragon' => typeDragon,
      'steel' => typeSteel,
      'fairy' => typeFairy,
      'dark' => typeDark,
      'stellar' => typeStellar,
      'shadow' => typeShadow,
      'unknown' => typeUnknown,
      _ => null,
    };
  }
}
