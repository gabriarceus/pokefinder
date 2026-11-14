import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/items_db.dart';
import 'package:pokefinder/l10n/locations_db.dart';
import 'package:pokefinder/l10n/moves_db.dart';
import 'package:pokefinder/l10n/translation_fallback.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

/// Formatter for converting [EvolutionTriggerDetail] into human-readable, localized trigger badges.
class EvolutionTriggerFormatter {
  const EvolutionTriggerFormatter._();
  static bool _isItalian(AppLocalizations l10n) => l10n.localeName == 'it';

  /// Localizes an item [slug] through the items database for Italian,
  /// falling back to title case (never a raw slug).
  static String _itemName(String slug, AppLocalizations l10n) {
    if (_isItalian(l10n)) {
      final translation = usableTranslationOrNull(
        itemsDb[slug.toLowerCase().trim()],
      );
      if (translation != null) return translation;
    }
    return slug.toDisplayCase();
  }

  /// Localizes a move [slug] through the moves database for Italian,
  /// falling back to title case (never a raw slug).
  static String _moveName(String slug, AppLocalizations l10n) {
    if (_isItalian(l10n)) {
      final translation = usableTranslationOrNull(
        movesDb[slug.toLowerCase().trim()],
      );
      if (translation != null) return translation;
    }
    return slug.toDisplayCase();
  }

  /// Localizes a location [slug] through an exact database lookup for
  /// Italian, falling back to title case (never a raw slug).
  static String _locationName(String slug, AppLocalizations l10n) {
    if (_isItalian(l10n)) {
      final translation = usableTranslationOrNull(
        locationsDb[slug.toLowerCase().trim()],
      );
      if (translation != null) return translation;
    }
    return slug.toDisplayCase();
  }

  /// Localizes a Pokémon [typeName] through [l10n], falling back to title
  /// case for unrecognized values.
  static String _typeName(String typeName, AppLocalizations l10n) {
    return l10n.translateTypeOrNull(typeName) ?? typeName.toDisplayCase();
  }

  /// Formats an [EvolutionTriggerDetail] into a concise label suitable for badges.
  static String format(
    EvolutionTriggerDetail detail, {
    required AppLocalizations l10n,
  }) {
    // 1. Shedinja special case
    if (detail.triggerType == EvolutionTriggerType.shed) {
      return l10n.evolutionTriggerShed;
    }

    // 2. Trade
    if (detail.triggerType == EvolutionTriggerType.trade) {
      if (detail.tradeSpecies != null) {
        final speciesName = detail.tradeSpecies!.toDisplayCase();
        return l10n.evolutionTriggerTradeSpecies(species: speciesName);
      }
      if (detail.heldItem != null) {
        final heldItemName = _itemName(detail.heldItem!, l10n);
        return l10n.evolutionTriggerTradeItem(item: heldItemName);
      }
      return l10n.evolutionTriggerTrade;
    }

    // 3. Min level with compound conditions
    if (detail.minLevel != null) {
      final level = detail.minLevel!;
      if (detail.turnUpsideDown) {
        return l10n.evolutionTriggerLevelUpsideDown(level: level);
      }
      if (detail.needsRain) {
        return l10n.evolutionTriggerLevelRain(level: level);
      }
      if (detail.relativePhysicalStats != null) {
        if (detail.relativePhysicalStats! > 0) {
          return l10n.evolutionTriggerLevelAtkGtDef(level: level);
        }
        if (detail.relativePhysicalStats! < 0) {
          return l10n.evolutionTriggerLevelDefGtAtk(level: level);
        }
        return l10n.evolutionTriggerLevelAtkEqDef(level: level);
      }
      if (detail.partySpecies != null) {
        final species = detail.partySpecies!.toDisplayCase();
        return l10n.evolutionTriggerLevelParty(level: level, species: species);
      }
      if (detail.partyType != null) {
        final type = _typeName(detail.partyType!, l10n);
        return l10n.evolutionTriggerLevelPartyType(level: level, type: type);
      }
      if (detail.gender == 1) {
        return l10n.evolutionTriggerLevelGenderFemale(level: level);
      }
      if (detail.gender == 2) {
        return l10n.evolutionTriggerLevelGenderMale(level: level);
      }
      if (detail.timeOfDay == 'day') {
        return l10n.evolutionTriggerLevelDay(level: level);
      }
      if (detail.timeOfDay == 'night') {
        return l10n.evolutionTriggerLevelNight(level: level);
      }
      return l10n.evolutionTriggerLevel(level: level);
    }

    // 4. Use item with possible constraints (gender, time of day)
    if (detail.item != null) {
      final itemName = _itemName(detail.item!, l10n);
      if (detail.gender == 1) {
        return l10n.evolutionTriggerItemGenderFemale(item: itemName);
      }
      if (detail.gender == 2) {
        return l10n.evolutionTriggerItemGenderMale(item: itemName);
      }
      if (detail.timeOfDay == 'day') {
        return l10n.evolutionTriggerItemDay(item: itemName);
      }
      if (detail.timeOfDay == 'night') {
        return l10n.evolutionTriggerItemNight(item: itemName);
      }
      return l10n.evolutionTriggerItem(item: itemName);
    }

    // 5. Level up holding an item (e.g. Razor Fang / Razor Claw / Oval Stone)
    if (detail.heldItem != null) {
      final itemName = _itemName(detail.heldItem!, l10n);
      if (detail.timeOfDay == 'day') {
        return l10n.evolutionTriggerHeldItemDay(item: itemName);
      }
      if (detail.timeOfDay == 'night') {
        return l10n.evolutionTriggerHeldItemNight(item: itemName);
      }
      return l10n.evolutionTriggerHeldItem(item: itemName);
    }

    // 6. Friendship / Happiness
    if (detail.minHappiness != null) {
      if (detail.timeOfDay == 'day') {
        return l10n.evolutionTriggerHappinessDay;
      }
      if (detail.timeOfDay == 'night') {
        return l10n.evolutionTriggerHappinessNight;
      }
      return l10n.evolutionTriggerHappiness;
    }

    // 7. Affection (e.g. Sylveon in Gen 6/7)
    if (detail.minAffection != null) {
      return l10n.evolutionTriggerAffection;
    }

    // 8. Beauty (e.g. Feebas -> Milotic)
    if (detail.minBeauty != null) {
      return l10n.evolutionTriggerBeauty;
    }

    // 9. Location
    if (detail.location != null) {
      final locName = _locationName(detail.location!, l10n);
      return l10n.evolutionTriggerLocation(location: locName);
    }

    // 10. Known Move
    if (detail.knownMove != null) {
      final moveName = _moveName(detail.knownMove!, l10n);
      return l10n.evolutionTriggerMove(move: moveName);
    }

    // 11. Move type
    if (detail.knownMoveType != null) {
      final typeName = _typeName(detail.knownMoveType!, l10n);
      return l10n.evolutionTriggerMove(move: '$typeName move');
    }

    // 12. Party species without minLevel (e.g. Mantyke)
    if (detail.partySpecies != null) {
      final species = detail.partySpecies!.toDisplayCase();
      return l10n.evolutionTriggerPartySpecies(species: species);
    }

    // 13. Party type without minLevel
    if (detail.partyType != null) {
      final type = _typeName(detail.partyType!, l10n);
      return l10n.evolutionTriggerPartyType(type: type);
    }

    // 14. Gender constraint alone
    if (detail.gender == 1) {
      return l10n.evolutionTriggerGenderFemale;
    }
    if (detail.gender == 2) {
      return l10n.evolutionTriggerGenderMale;
    }

    // 15. Device upside down without minLevel
    if (detail.turnUpsideDown) {
      return l10n.evolutionTriggerTurnUpsideDown;
    }

    // 16. Overworld rain without minLevel
    if (detail.needsRain) {
      return l10n.evolutionTriggerRain;
    }

    // 17. Other / special condition
    return l10n.evolutionTriggerOther;
  }
}
