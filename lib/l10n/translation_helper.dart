import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/abilities_db.dart';
import 'package:pokefinder/l10n/moves_db.dart';
import 'package:pokefinder/l10n/locations_db.dart';

extension TranslationExtension on BuildContext {
  String translateAbility(String name) {
    final key = name.toLowerCase().trim();
    final locale = Localizations.localeOf(this);

    if (locale.languageCode == 'it') {
      final translation = abilitiesDb[key];
      if (translation != null) {
        return translation;
      }
    }
    return _formatDefault(name);
  }

  String translateMove(String name) {
    final key = name.toLowerCase().trim();
    final locale = Localizations.localeOf(this);

    if (locale.languageCode == 'it') {
      final translation = movesDb[key];
      if (translation != null) {
        return translation;
      }
    }
    return _formatDefault(name);
  }

  String translateLocation(String rawName) {
    final locale = Localizations.localeOf(this);
    if (locale.languageCode == 'it') {
      return _translateLocationToItalian(rawName);
    }
    return _formatDefault(rawName);
  }

  String translateGameVersion(String gameName) {
    final t = AppLocalizations.of(this);
    final key = gameName.toLowerCase().trim();
    switch (key) {
      case 'red': return t.gameRed;
      case 'blue': return t.gameBlue;
      case 'yellow': return t.gameYellow;
      case 'gold': return t.gameGold;
      case 'silver': return t.gameSilver;
      case 'crystal': return t.gameCrystal;
      case 'ruby': return t.gameRuby;
      case 'sapphire': return t.gameSapphire;
      case 'emerald': return t.gameEmerald;
      case 'firered': return t.gameFirered;
      case 'leafgreen': return t.gameLeafgreen;
      case 'diamond': return t.gameDiamond;
      case 'pearl': return t.gamePearl;
      case 'platinum': return t.gamePlatinum;
      case 'heartgold': return t.gameHeartgold;
      case 'soulsilver': return t.gameSoulsilver;
      case 'black': return t.gameBlack;
      case 'white': return t.gameWhite;
      case 'black-2': return t.gameBlack2;
      case 'white-2': return t.gameWhite2;
      case 'x': return t.gameX;
      case 'y': return t.gameY;
      case 'omega-ruby': return t.gameOmegaRuby;
      case 'alpha-sapphire': return t.gameAlphaSapphire;
      case 'sun': return t.gameSun;
      case 'moon': return t.gameMoon;
      case 'ultra-sun': return t.gameUltraSun;
      case 'ultra-moon': return t.gameUltraMoon;
      case 'lets-go-pikachu': return t.gameLetsGoPikachu;
      case 'lets-go-eevee': return t.gameLetsGoEevee;
      case 'sword': return t.gameSword;
      case 'shield': return t.gameShield;
      case 'the-isle-of-armor': return t.gameTheIsleOfArmor;
      case 'the-crown-tundra': return t.gameTheCrownTundra;
      case 'legends-arceus': return t.gameLegendsArceus;
      case 'scarlet': return t.gameScarlet;
      case 'violet': return t.gameViolet;
      case 'the-teal-mask': return t.gameTheTealMask;
      case 'the-indigo-disk': return t.gameTheIndigoDisk;
      case 'colosseum': return t.gameColosseum;
      case 'xd': return t.gameXd;
      // Groups:
      case 'red-blue': return t.gameGroupRedBlue;
      case 'gold-silver': return t.gameGroupGoldSilver;
      case 'ruby-sapphire': return t.gameGroupRubySapphire;
      case 'firered-leafgreen': return t.gameGroupFireredLeafgreen;
      case 'diamond-pearl': return t.gameGroupDiamondPearl;
      case 'heartgold-soulsilver': return t.gameGroupHeartgoldSoulsilver;
      case 'black-white': return t.gameGroupBlackWhite;
      case 'black-2-white-2': return t.gameGroupBlack2White2;
      case 'x-y': return t.gameGroupXY;
      case 'omega-ruby-alpha-sapphire': return t.gameGroupOmegaRubyAlphaSapphire;
      case 'sun-moon': return t.gameGroupSunMoon;
      case 'ultra-sun-ultra-moon': return t.gameGroupUltraSunUltraMoon;
      case 'lets-go-pikachu-lets-go-eevee': return t.gameGroupLetsGoPikachuLetsGoEevee;
      case 'sword-shield': return t.gameGroupSwordShield;
      case 'scarlet-violet': return t.gameGroupScarletViolet;
      default: return _formatDefault(gameName);
    }
  }

  String translateType(String typeName) {
    final t = AppLocalizations.of(this);
    final key = typeName.toLowerCase().trim();
    switch (key) {
      case 'normal': return t.typeNormal;
      case 'fire': return t.typeFire;
      case 'water': return t.typeWater;
      case 'grass': return t.typeGrass;
      case 'electric': return t.typeElectric;
      case 'ice': return t.typeIce;
      case 'fighting': return t.typeFighting;
      case 'poison': return t.typePoison;
      case 'ground': return t.typeGround;
      case 'flying': return t.typeFlying;
      case 'psychic': return t.typePsychic;
      case 'bug': return t.typeBug;
      case 'rock': return t.typeRock;
      case 'ghost': return t.typeGhost;
      case 'dragon': return t.typeDragon;
      case 'steel': return t.typeSteel;
      case 'fairy': return t.typeFairy;
      case 'dark': return t.typeDark;
      case 'stellar': return t.typeStellar;
      case 'shadow': return t.typeShadow;
      case 'unknown': return t.typeUnknown;
      default: return _capitalize(typeName);
    }
  }

  String _translateLocationToItalian(String rawName) {
    String name = rawName.toLowerCase().trim();

    // 1. Match routes, e.g. "sinnoh-route-201", "kanto-route-1", "kanto-route-1-area"
    final routeRegExp = RegExp(r'^([a-z\-]+)-route-(\d+)(.*)$');
    final match = routeRegExp.firstMatch(name);
    if (match != null) {
      final region = match.group(1)!;
      final routeNumber = match.group(2)!;
      final suffix = match.group(3) ?? '';

      final translatedRegion = locationsDb[region] ?? _capitalize(region);
      final translatedSuffix = _translateLocationSuffix(suffix);

      return 'Percorso $routeNumber ($translatedRegion)$translatedSuffix';
    }

    // 2. Lookup other locations using length-descending order to avoid partial matches
    String translated = name;
    final sortedKeys = locationsDb.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final key in sortedKeys) {
      if (translated.contains(key)) {
        final replacement = locationsDb[key]!;
        translated = translated.replaceFirst(key, '##$replacement##');
      }
    }

    // 3. Translate suffix parts
    translated = _translateLocationSuffix(translated);

    // 4. Remove the ## markers
    translated = translated.replaceAll('##', '');

    // 5. Clean up duplicate spaces and capitalize words
    return _capitalizeWords(translated);
  }

  String _translateLocationSuffix(String suffix) {
    return suffix
        .replaceAll('-area', ' area')
        .replaceAll('-entrance', ' ingresso')
        .replaceAll('-exterior', ' esterno')
        .replaceAll('-hideout', ' rifugio')
        .replaceAll('-inside', ' interno')
        .replaceAll('-1f', ' 1F')
        .replaceAll('-2f', ' 2F')
        .replaceAll('-3f', ' 3F')
        .replaceAll('-4f', ' 4F')
        .replaceAll('-5f', ' 5F')
        .replaceAll('-6f', ' 6F')
        .replaceAll('-7f', ' 7F')
        .replaceAll('-b1f', ' B1F')
        .replaceAll('-b2f', ' B2F')
        .replaceAll('-b3f', ' B3F')
        .replaceAll('-b4f', ' B4F')
        .replaceAll('-', ' ');
  }

  String _formatDefault(String name) {
    return name
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  String _capitalizeWords(String s) {
    return s
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
