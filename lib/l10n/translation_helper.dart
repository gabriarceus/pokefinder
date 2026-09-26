import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/abilities_db.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/items_db.dart';
import 'package:pokefinder/l10n/locations_db.dart';
import 'package:pokefinder/l10n/moves_db.dart';
import 'package:pokefinder/l10n/translation_fallback.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

/// Bundled translations per language code, for each kind of PokeAPI slug.
const Map<String, Map<String, String>> _abilitiesByLocale = {'it': abilitiesDb};
const Map<String, Map<String, String>> _movesByLocale = {'it': movesDb};
const Map<String, Map<String, String>> _itemsByLocale = {'it': itemsDb};
const Map<String, Map<String, String>> _locationsByLocale = {'it': locationsDb};

/// Italian word for "route" in location names.
const Map<String, String> _routeWordByLocale = {'it': 'Percorso'};

/// Returns the [languageCode] translation of [slug] from [dbByLocale], or the
/// title-cased slug when there is none.
String _translate(
  Map<String, Map<String, String>> dbByLocale,
  String slug,
  String languageCode,
) {
  final key = slug.toLowerCase().trim();
  return usableTranslationOrNull(dbByLocale[languageCode]?[key]) ??
      slug.toDisplayCase();
}

/// Returns the display name of the move [slug] in [languageCode].
String translateMoveSlug(String slug, String languageCode) =>
    _translate(_movesByLocale, slug, languageCode);

final _routePattern = RegExp(r'^([a-z\-]+)-route-(\d+)(-area)?$');
final _floorPattern = RegExp(r'^(.+)-(b?\d+f)$');

/// Returns the display name of the location [slug] in [languageCode].
///
/// The name is translated as a whole or not at all: when any part has no
/// translation, the whole title-cased English name is returned.
String translateLocationSlug(String slug, String languageCode) {
  final english = slug.toDisplayCase();
  final db = _locationsByLocale[languageCode];
  if (db == null) return english;

  var key = slug.toLowerCase().trim();
  final route = _routePattern.firstMatch(key);
  if (route != null) {
    final region = usableTranslationOrNull(db[route.group(1)]);
    final routeWord = _routeWordByLocale[languageCode];
    if (region == null || routeWord == null) return english;
    return '$routeWord ${route.group(2)} ($region)';
  }

  if (!db.containsKey(key) && key.endsWith('-area')) {
    key = key.substring(0, key.length - '-area'.length);
  }
  final floor = _floorPattern.firstMatch(key);
  final base = floor != null && !db.containsKey(key) ? floor.group(1)! : key;
  final translated = usableTranslationOrNull(db[base]);
  if (translated == null) return english;
  return base == key
      ? translated
      : '$translated ${floor!.group(2)!.toUpperCase()}';
}

/// Localized names of game versions and version groups, keyed by slug.
final Map<String, String Function(AppLocalizations)> _gameNames = {
  'red': (t) => t.gameRed,
  'blue': (t) => t.gameBlue,
  'yellow': (t) => t.gameYellow,
  'gold': (t) => t.gameGold,
  'silver': (t) => t.gameSilver,
  'crystal': (t) => t.gameCrystal,
  'ruby': (t) => t.gameRuby,
  'sapphire': (t) => t.gameSapphire,
  'emerald': (t) => t.gameEmerald,
  'firered': (t) => t.gameFirered,
  'leafgreen': (t) => t.gameLeafgreen,
  'diamond': (t) => t.gameDiamond,
  'pearl': (t) => t.gamePearl,
  'platinum': (t) => t.gamePlatinum,
  'heartgold': (t) => t.gameHeartgold,
  'soulsilver': (t) => t.gameSoulsilver,
  'black': (t) => t.gameBlack,
  'white': (t) => t.gameWhite,
  'black-2': (t) => t.gameBlack2,
  'white-2': (t) => t.gameWhite2,
  'x': (t) => t.gameX,
  'y': (t) => t.gameY,
  'omega-ruby': (t) => t.gameOmegaRuby,
  'alpha-sapphire': (t) => t.gameAlphaSapphire,
  'sun': (t) => t.gameSun,
  'moon': (t) => t.gameMoon,
  'ultra-sun': (t) => t.gameUltraSun,
  'ultra-moon': (t) => t.gameUltraMoon,
  'lets-go-pikachu': (t) => t.gameLetsGoPikachu,
  'lets-go-eevee': (t) => t.gameLetsGoEevee,
  'sword': (t) => t.gameSword,
  'shield': (t) => t.gameShield,
  'the-isle-of-armor': (t) => t.gameTheIsleOfArmor,
  'the-crown-tundra': (t) => t.gameTheCrownTundra,
  'legends-arceus': (t) => t.gameLegendsArceus,
  'scarlet': (t) => t.gameScarlet,
  'violet': (t) => t.gameViolet,
  'the-teal-mask': (t) => t.gameTheTealMask,
  'the-indigo-disk': (t) => t.gameTheIndigoDisk,
  'colosseum': (t) => t.gameColosseum,
  'xd': (t) => t.gameXd,
  'red-blue': (t) => t.gameGroupRedBlue,
  'gold-silver': (t) => t.gameGroupGoldSilver,
  'ruby-sapphire': (t) => t.gameGroupRubySapphire,
  'firered-leafgreen': (t) => t.gameGroupFireredLeafgreen,
  'diamond-pearl': (t) => t.gameGroupDiamondPearl,
  'heartgold-soulsilver': (t) => t.gameGroupHeartgoldSoulsilver,
  'black-white': (t) => t.gameGroupBlackWhite,
  'black-2-white-2': (t) => t.gameGroupBlack2White2,
  'x-y': (t) => t.gameGroupXY,
  'omega-ruby-alpha-sapphire': (t) => t.gameGroupOmegaRubyAlphaSapphire,
  'sun-moon': (t) => t.gameGroupSunMoon,
  'ultra-sun-ultra-moon': (t) => t.gameGroupUltraSunUltraMoon,
  'lets-go-pikachu-lets-go-eevee': (t) => t.gameGroupLetsGoPikachuLetsGoEevee,
  'sword-shield': (t) => t.gameGroupSwordShield,
  'scarlet-violet': (t) => t.gameGroupScarletViolet,
};

extension TranslationExtension on BuildContext {
  String get _languageCode => Localizations.localeOf(this).languageCode;

  /// Returns the localized display name for [entry].
  String translatePokemonIndexEntry(PokemonIndexEntry entry) {
    return entry.getDisplayName(languageCode: _languageCode);
  }

  String translateAbility(String name) =>
      _translate(_abilitiesByLocale, name, _languageCode);

  String translateMove(String name) => translateMoveSlug(name, _languageCode);

  /// Returns the localized display name for a held/evolution [item] slug.
  ///
  /// Falls back to title case, never to a raw UPPER-CASED slug.
  String translateItem(String name) =>
      _translate(_itemsByLocale, name, _languageCode);

  String translateLocation(String rawName) =>
      translateLocationSlug(rawName, _languageCode);

  String translateGameVersion(String gameName) {
    final name = _gameNames[gameName.toLowerCase().trim()];
    return name != null
        ? name(AppLocalizations.of(this))
        : gameName.toDisplayCase();
  }

  /// Returns the localized name of the Pokémon [typeName], or null when the
  /// value is not a recognized type.
  String? translateTypeOrNull(String typeName) {
    return AppLocalizations.of(this).translateTypeOrNull(typeName);
  }

  /// Returns the localized name of the Pokémon [typeName], falling back to a
  /// capitalized form of the raw value when the type is not recognized.
  String translateType(String typeName) {
    return translateTypeOrNull(typeName) ?? typeName.capitalize();
  }

  String translateDamageClass(DamageClass? damageClass) {
    if (damageClass == null) return '-';
    final t = AppLocalizations.of(this);
    return switch (damageClass) {
      DamageClass.physical => t.damageClassPhysical,
      DamageClass.special => t.damageClassSpecial,
      DamageClass.status => t.damageClassStatus,
    };
  }
}
