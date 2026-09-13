import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/canonical_species_data.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

/// Pure domain utility for classifying Pokémon alternate forms, resolving parent
/// species in O(1) time, formatting localized display titles, and tracking generation bounds.
class PokemonFormClassifier {
  const PokemonFormClassifier._();

  /// Default generation bounds helper for canonical Pokémon IDs.
  static int resolveGeneration(int id) {
    if (id >= 1 && id <= 151) return 1;
    if (id >= 152 && id <= 251) return 2;
    if (id >= 252 && id <= 386) return 3;
    if (id >= 387 && id <= 493) return 4;
    if (id >= 494 && id <= 649) return 5;
    if (id >= 650 && id <= 721) return 6;
    if (id >= 722 && id <= 809) return 7;
    if (id >= 810 && id <= 905) return 8;
    if (id >= 906 && id <= 1025) return 9;
    return 0;
  }

  /// Resolves the canonical parent species numeric Pokédex ID for [name] and [id] in O(1) time.
  static int resolveParentSpeciesId(
    String name, {
    int? id,
    Map<String, int>? canonicalLookup,
  }) {
    if (id != null && id > 0 && id <= 1025) {
      return id;
    }

    final lookup = canonicalLookup ?? kCanonicalSpeciesNameToId;
    if (lookup.containsKey(name)) {
      return lookup[name]!;
    }

    final parts = name.split('-');
    for (var i = parts.length - 1; i >= 1; i--) {
      final candidate = parts.sublist(0, i).join('-');
      if (lookup.containsKey(candidate)) {
        return lookup[candidate]!;
      }
    }

    return id ?? 0;
  }

  /// Resolves the canonical parent species name slug for [parentId].
  static String resolveParentSpeciesName(
    int parentId, {
    Map<int, String>? idToNameLookup,
    String fallback = '',
  }) {
    final lookup = idToNameLookup ?? kCanonicalSpeciesIdToName;
    return lookup[parentId] ?? fallback;
  }

  /// Classifies the [PokemonFormCategory] of a Pokémon from its wire name and ID.
  static PokemonFormCategory classifyCategory(String name, {int? id}) {
    if ((id != null && id > 0 && id <= 1025) ||
        (id == null && kCanonicalSpeciesNameToId.containsKey(name))) {
      return PokemonFormCategory.canonical;
    }

    if (name.endsWith('-mega') ||
        name.endsWith('-mega-x') ||
        name.endsWith('-mega-y')) {
      return PokemonFormCategory.mega;
    }

    if (name.endsWith('-primal')) {
      return PokemonFormCategory.primal;
    }

    if (name.contains('-alola') ||
        name.contains('-galar') ||
        name.contains('-hisui') ||
        name.contains('-paldea')) {
      return PokemonFormCategory.regional;
    }

    if (name.endsWith('-gmax')) {
      return PokemonFormCategory.gmax;
    }

    if (_isCosmetic(name)) {
      return PokemonFormCategory.cosmetic;
    }

    return PokemonFormCategory.battleMode;
  }

  /// Resolves the [PokemonRegionalGroup] if this form is regional, otherwise null.
  static PokemonRegionalGroup? resolveRegionalGroup(String name) {
    if (name.contains('-alola')) return PokemonRegionalGroup.alola;
    if (name.contains('-galar')) return PokemonRegionalGroup.galar;
    if (name.contains('-hisui')) return PokemonRegionalGroup.hisui;
    if (name.contains('-paldea')) return PokemonRegionalGroup.paldea;
    return null;
  }

  /// Resolves the franchise introduction generation when the form or species debuted.
  static int resolveIntroductionGeneration({
    required String name,
    required PokemonFormCategory category,
    PokemonRegionalGroup? regionalGroup,
    required int parentSpeciesId,
  }) {
    switch (category) {
      case PokemonFormCategory.canonical:
        return resolveGeneration(parentSpeciesId);
      case PokemonFormCategory.mega:
      case PokemonFormCategory.primal:
        return 6;
      case PokemonFormCategory.regional:
        return switch (regionalGroup) {
          PokemonRegionalGroup.alola => 7,
          PokemonRegionalGroup.galar => 8,
          PokemonRegionalGroup.hisui => 8,
          PokemonRegionalGroup.paldea => 9,
          null => 7,
        };
      case PokemonFormCategory.gmax:
        return 8;
      case PokemonFormCategory.cosmetic:
        if (name.contains('-totem')) return 7;
        return resolveGeneration(parentSpeciesId);
      case PokemonFormCategory.battleMode:
        if (name.contains('zygarde')) return 7;
        if (name.contains('necrozma')) return 7;
        if (name.contains('calyrex') || name.contains('enamorus')) return 8;
        if (name.contains('palafin') ||
            name.contains('ogerpon') ||
            name.contains('terapagos')) {
          return 9;
        }
        return resolveGeneration(parentSpeciesId);
    }
  }

  /// Formats official Pokémon display name with localized English and Italian support.
  static String formatDisplayName({
    required String name,
    required String parentSpeciesName,
    required PokemonFormCategory category,
    PokemonRegionalGroup? regionalGroup,
    String languageCode = 'en',
  }) {
    final cleanParent = _cleanCanonicalDisplayName(parentSpeciesName);
    final isIt = languageCode.toLowerCase().startsWith('it');

    switch (category) {
      case PokemonFormCategory.canonical:
        return _cleanCanonicalDisplayName(name);

      case PokemonFormCategory.mega:
        if (name.endsWith('-mega-x')) return 'Mega $cleanParent X';
        if (name.endsWith('-mega-y')) return 'Mega $cleanParent Y';
        return 'Mega $cleanParent';

      case PokemonFormCategory.primal:
        return isIt ? 'Archeo $cleanParent' : 'Primal $cleanParent';

      case PokemonFormCategory.regional:
        final group = regionalGroup ?? resolveRegionalGroup(name);
        return switch (group) {
          PokemonRegionalGroup.alola =>
            isIt ? '$cleanParent di Alola' : 'Alolan $cleanParent',
          PokemonRegionalGroup.galar =>
            isIt ? '$cleanParent di Galar' : 'Galarian $cleanParent',
          PokemonRegionalGroup.hisui =>
            isIt ? '$cleanParent di Hisui' : 'Hisuian $cleanParent',
          PokemonRegionalGroup.paldea =>
            isIt ? '$cleanParent di Paldea' : 'Paldean $cleanParent',
          null => '$cleanParent (${category.name.toDisplayCase()})',
        };

      case PokemonFormCategory.gmax:
        return isIt ? '$cleanParent Gigamax' : 'Gigantamax $cleanParent';

      case PokemonFormCategory.battleMode:
        return _formatBattleModeName(
          name: name,
          cleanParent: cleanParent,
          isItalian: isIt,
        );

      case PokemonFormCategory.cosmetic:
        return _formatCosmeticName(
          name: name,
          cleanParent: cleanParent,
          isItalian: isIt,
        );
    }
  }

  /// Enriches a list of [PokemonIndexEntry] with parent resolution, classification,
  /// and tracks available alternate forms on canonical species entries.
  static List<PokemonIndexEntry> enrichEntries(
    List<PokemonIndexEntry> entries, {
    Map<String, int>? canonicalLookup,
    Map<int, String>? idToNameLookup,
  }) {
    final nameLookup = canonicalLookup ?? kCanonicalSpeciesNameToId;
    final idLookup = idToNameLookup ?? kCanonicalSpeciesIdToName;

    // Track which parent species have alternate forms and their categories
    final formsByParentId = <int, Set<PokemonFormCategory>>{};

    final preClassified = entries.map((entry) {
      final category = classifyCategory(entry.name, id: entry.id);
      final regionalGroup = resolveRegionalGroup(entry.name);
      final parentId = resolveParentSpeciesId(
        entry.name,
        id: entry.id,
        canonicalLookup: nameLookup,
      );
      final parentName = resolveParentSpeciesName(
        parentId,
        idToNameLookup: idLookup,
        fallback: entry.name,
      );
      final introGen = resolveIntroductionGeneration(
        name: entry.name,
        category: category,
        regionalGroup: regionalGroup,
        parentSpeciesId: parentId,
      );
      final speciesGen = resolveGeneration(parentId);

      if (category != PokemonFormCategory.canonical) {
        formsByParentId.putIfAbsent(parentId, () => {}).add(category);
      }

      return entry.copyWith(
        parentSpeciesId: parentId,
        parentSpeciesName: parentName,
        formCategory: category,
        regionalGroup: regionalGroup,
        introductionGeneration: introGen,
        speciesGeneration: speciesGen,
      );
    }).toList();

    return preClassified.map((entry) {
      final availableForms =
          formsByParentId[entry.id] ?? const <PokemonFormCategory>{};
      final hasForms = availableForms.isNotEmpty;

      return entry.copyWith(
        hasAlternateForms: hasForms,
        availableFormCategories: availableForms.toList(),
      );
    }).toList();
  }

  static bool _isCosmetic(String name) {
    if (name.contains('-cap') ||
        name.contains('-costume') ||
        name.contains('-totem') ||
        name.contains('-cosplay') ||
        name.contains('-starter') ||
        name.startsWith('pikachu-rock-star') ||
        name.startsWith('pikachu-belle') ||
        name.startsWith('pikachu-pop-star') ||
        name.startsWith('pikachu-phd') ||
        name.startsWith('pikachu-libre') ||
        name.contains('magearna-original') ||
        name.contains('zarude-dada')) {
      return true;
    }
    return false;
  }

  static String _cleanCanonicalDisplayName(String name) {
    const defaultSuffixes = [
      '-normal',
      '-altered',
      '-land',
      '-standard',
      '-incarnate',
      '-ordinary',
      '-aria',
      '-male',
      '-shield',
      '-average',
      '-50',
      '-baile',
      '-midday',
      '-solo',
      '-red-meteor',
      '-disguised',
      '-amped',
      '-ice',
      '-full-belly',
      '-single-strike',
      '-plant',
      '-red-striped',
      '-two-segment',
      '-zero',
      '-family-of-four',
      '-curly',
      '-green-plumage',
    ];

    var clean = name;
    for (final suffix in defaultSuffixes) {
      if (clean.endsWith(suffix)) {
        clean = clean.substring(0, clean.length - suffix.length);
        break;
      }
    }

    if (clean == 'mr-mime') return 'Mr. Mime';
    if (clean == 'mr-rime') return 'Mr. Rime';
    if (clean == 'mime-jr') return 'Mime Jr.';
    if (clean == 'ho-oh') return 'Ho-Oh';
    if (clean == 'porygon-z') return 'Porygon-Z';
    if (clean == 'type-null') return 'Type: Null';
    if (clean == 'jangmo-o') return 'Jangmo-o';
    if (clean == 'hakamo-o') return 'Hakamo-o';
    if (clean == 'kommo-o') return 'Kommo-o';
    if (clean == 'tapu-koko') return 'Tapu Koko';
    if (clean == 'tapu-lele') return 'Tapu Lele';
    if (clean == 'tapu-bulu') return 'Tapu Bulu';
    if (clean == 'tapu-fini') return 'Tapu Fini';
    if (clean == 'ting-lu') return 'Ting-Lu';
    if (clean == 'chien-pao') return 'Chien-Pao';
    if (clean == 'wo-chien') return 'Wo-Chien';
    if (clean == 'chi-yu') return 'Chi-Yu';

    return clean.toDisplayCase();
  }

  static String _formatBattleModeName({
    required String name,
    required String cleanParent,
    required bool isItalian,
  }) {
    if (name.startsWith('rotom-')) {
      final suffix = name.substring('rotom-'.length);
      return switch (suffix) {
        'wash' => isItalian ? 'Rotom (Lavaggio)' : 'Rotom (Wash)',
        'heat' => isItalian ? 'Rotom (Calore)' : 'Rotom (Heat)',
        'frost' => isItalian ? 'Rotom (Gelo)' : 'Rotom (Frost)',
        'fan' => isItalian ? 'Rotom (Vortice)' : 'Rotom (Fan)',
        'mow' => isItalian ? 'Rotom (Taglio)' : 'Rotom (Mow)',
        _ => 'Rotom (${suffix.toDisplayCase()})',
      };
    }

    if (name.startsWith('deoxys-')) {
      final suffix = name.substring('deoxys-'.length);
      return switch (suffix) {
        'attack' => isItalian ? 'Deoxys (Attacco)' : 'Deoxys (Attack)',
        'defense' => isItalian ? 'Deoxys (Difesa)' : 'Deoxys (Defense)',
        'speed' => isItalian ? 'Deoxys (Velocità)' : 'Deoxys (Speed)',
        _ => 'Deoxys (${suffix.toDisplayCase()})',
      };
    }

    if (name == 'giratina-origin') {
      return isItalian ? 'Giratina (Origine)' : 'Giratina (Origin)';
    }

    if (name == 'shaymin-sky') {
      return isItalian ? 'Shaymin (Cielo)' : 'Shaymin (Sky)';
    }

    if (name == 'aegislash-blade') {
      return isItalian ? 'Aegislash (Spada)' : 'Aegislash (Blade)';
    }

    final prefix = '${cleanParent.toLowerCase().replaceAll(' ', '-')}-';
    final formPart = name.startsWith(prefix)
        ? name.substring(prefix.length)
        : name;
    return '$cleanParent (${formPart.replaceAll('-', ' ').toDisplayCase()})';
  }

  static String _formatCosmeticName({
    required String name,
    required String cleanParent,
    required bool isItalian,
  }) {
    final prefix = '${cleanParent.toLowerCase().replaceAll(' ', '-')}-';
    final formPart = name.startsWith(prefix)
        ? name.substring(prefix.length)
        : name;
    return '$cleanParent (${formPart.replaceAll('-', ' ').toDisplayCase()})';
  }

  /// Resolves the primary and secondary [PokemonType] for an alternate form,
  /// falling back to the base species types when form types are identical or unspecialized.
  static (PokemonType?, PokemonType?) resolveFormTypes({
    required String formName,
    PokemonType? baseType1,
    PokemonType? baseType2,
  }) {
    final lower = formName.toLowerCase();

    // 1. Regional forms
    if (lower.contains('-alola')) {
      if (lower.contains('rattata') || lower.contains('raticate')) {
        return (PokemonType.dark, PokemonType.normal);
      }
      if (lower.contains('raichu')) {
        return (PokemonType.electric, PokemonType.psychic);
      }
      if (lower.contains('sandshrew') || lower.contains('sandslash')) {
        return (PokemonType.ice, PokemonType.steel);
      }
      if (lower.contains('vulpix')) {
        return (PokemonType.ice, null);
      }
      if (lower.contains('ninetales')) {
        return (PokemonType.ice, PokemonType.fairy);
      }
      if (lower.contains('diglett') || lower.contains('dugtrio')) {
        return (PokemonType.ground, PokemonType.steel);
      }
      if (lower.contains('meowth') || lower.contains('persian')) {
        return (PokemonType.dark, null);
      }
      if (lower.contains('geodude') ||
          lower.contains('graveler') ||
          lower.contains('golem')) {
        return (PokemonType.rock, PokemonType.electric);
      }
      if (lower.contains('grimer') || lower.contains('muk')) {
        return (PokemonType.poison, PokemonType.dark);
      }
      if (lower.contains('exeggutor')) {
        return (PokemonType.grass, PokemonType.dragon);
      }
      if (lower.contains('marowak')) {
        return (PokemonType.fire, PokemonType.ghost);
      }
    }

    if (lower.contains('-galar')) {
      if (lower.contains('meowth')) return (PokemonType.steel, null);
      if (lower.contains('ponyta')) return (PokemonType.psychic, null);
      if (lower.contains('rapidash')) {
        return (PokemonType.psychic, PokemonType.fairy);
      }
      if (lower.contains('slowpoke')) return (PokemonType.psychic, null);
      if (lower.contains('slowbro') || lower.contains('slowking')) {
        return (PokemonType.poison, PokemonType.psychic);
      }
      if (lower.contains('farfetchd')) return (PokemonType.fighting, null);
      if (lower.contains('weezing')) {
        return (PokemonType.poison, PokemonType.fairy);
      }
      if (lower.contains('mr-mime')) {
        return (PokemonType.ice, PokemonType.psychic);
      }
      if (lower.contains('articuno')) {
        return (PokemonType.psychic, PokemonType.flying);
      }
      if (lower.contains('zapdos')) {
        return (PokemonType.fighting, PokemonType.flying);
      }
      if (lower.contains('moltres')) {
        return (PokemonType.dark, PokemonType.flying);
      }
      if (lower.contains('corsola')) return (PokemonType.ghost, null);
      if (lower.contains('zigzagoon') || lower.contains('linoone')) {
        return (PokemonType.dark, PokemonType.normal);
      }
      if (lower.contains('darumaka')) return (PokemonType.ice, null);
      if (lower.contains('darmanitan-galar-zen')) {
        return (PokemonType.ice, PokemonType.fire);
      }
      if (lower.contains('darmanitan')) return (PokemonType.ice, null);
      if (lower.contains('yamask')) {
        return (PokemonType.ground, PokemonType.ghost);
      }
      if (lower.contains('stunfisk')) {
        return (PokemonType.ground, PokemonType.steel);
      }
    }

    if (lower.contains('-hisui')) {
      if (lower.contains('growlithe') || lower.contains('arcanine')) {
        return (PokemonType.fire, PokemonType.rock);
      }
      if (lower.contains('voltorb') || lower.contains('electrode')) {
        return (PokemonType.electric, PokemonType.grass);
      }
      if (lower.contains('typhlosion')) {
        return (PokemonType.fire, PokemonType.ghost);
      }
      if (lower.contains('qwilfish')) {
        return (PokemonType.dark, PokemonType.poison);
      }
      if (lower.contains('sneasel')) {
        return (PokemonType.fighting, PokemonType.poison);
      }
      if (lower.contains('samurott')) {
        return (PokemonType.water, PokemonType.dark);
      }
      if (lower.contains('lilligant')) {
        return (PokemonType.grass, PokemonType.fighting);
      }
      if (lower.contains('zorua') || lower.contains('zoroark')) {
        return (PokemonType.normal, PokemonType.ghost);
      }
      if (lower.contains('braviary')) {
        return (PokemonType.psychic, PokemonType.flying);
      }
      if (lower.contains('sliggoo') || lower.contains('goodra')) {
        return (PokemonType.steel, PokemonType.dragon);
      }
      if (lower.contains('avalugg')) return (PokemonType.ice, PokemonType.rock);
      if (lower.contains('decidueye')) {
        return (PokemonType.grass, PokemonType.fighting);
      }
    }

    if (lower.contains('-paldea')) {
      if (lower.contains('wooper')) {
        return (PokemonType.poison, PokemonType.ground);
      }
      if (lower.contains('blaze-breed')) {
        return (PokemonType.fighting, PokemonType.fire);
      }
      if (lower.contains('aqua-breed')) {
        return (PokemonType.fighting, PokemonType.water);
      }
      if (lower.contains('tauros')) return (PokemonType.fighting, null);
    }

    // 2. Megas with type changes
    if (lower.endsWith('-mega-x') && lower.startsWith('charizard')) {
      return (PokemonType.fire, PokemonType.dragon);
    }
    if (lower.endsWith('-mega-x') && lower.startsWith('mewtwo')) {
      return (PokemonType.psychic, PokemonType.fighting);
    }
    if (lower.contains('pinsir-mega')) {
      return (PokemonType.bug, PokemonType.flying);
    }
    if (lower.contains('gyarados-mega')) {
      return (PokemonType.water, PokemonType.dark);
    }
    if (lower.contains('ampharos-mega')) {
      return (PokemonType.electric, PokemonType.dragon);
    }
    if (lower.contains('sceptile-mega')) {
      return (PokemonType.grass, PokemonType.dragon);
    }
    if (lower.contains('aggron-mega')) {
      return (PokemonType.steel, null);
    }
    if (lower.contains('altaria-mega')) {
      return (PokemonType.dragon, PokemonType.fairy);
    }
    if (lower.contains('lopunny-mega')) {
      return (PokemonType.normal, PokemonType.fighting);
    }

    // 3. Rotom forms
    if (lower.startsWith('rotom-')) {
      if (lower.endsWith('-wash')) {
        return (PokemonType.electric, PokemonType.water);
      }
      if (lower.endsWith('-heat')) {
        return (PokemonType.electric, PokemonType.fire);
      }
      if (lower.endsWith('-frost')) {
        return (PokemonType.electric, PokemonType.ice);
      }
      if (lower.endsWith('-fan')) {
        return (PokemonType.electric, PokemonType.flying);
      }
      if (lower.endsWith('-mow')) {
        return (PokemonType.electric, PokemonType.grass);
      }
    }

    // 4. Type suffix forms (e.g. arceus-fire, silvally-water)
    final parts = lower.split('-');
    if (parts.length > 1) {
      final suffix = parts.last;
      final parsedType = PokemonType.fromApiName(suffix);
      if (parsedType != null) {
        return (parsedType, null);
      }
    }

    return (baseType1, baseType2);
  }
}
