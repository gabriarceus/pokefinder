import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('PokemonFormClassifier', () {
    test('classifies all major form categories correctly', () {
      expect(
        PokemonFormClassifier.classifyCategory('charizard-mega-x', id: 10034),
        PokemonFormCategory.mega,
      );
      expect(
        PokemonFormClassifier.classifyCategory('venusaur-mega', id: 10033),
        PokemonFormCategory.mega,
      );
      expect(
        PokemonFormClassifier.classifyCategory('kyogre-primal', id: 10077),
        PokemonFormCategory.primal,
      );
      expect(
        PokemonFormClassifier.classifyCategory('vulpix-alola', id: 10103),
        PokemonFormCategory.regional,
      );
      expect(
        PokemonFormClassifier.classifyCategory('meowth-galar', id: 10161),
        PokemonFormCategory.regional,
      );
      expect(
        PokemonFormClassifier.classifyCategory('zorua-hisui', id: 10238),
        PokemonFormCategory.regional,
      );
      expect(
        PokemonFormClassifier.classifyCategory('wooper-paldea', id: 10253),
        PokemonFormCategory.regional,
      );
      expect(
        PokemonFormClassifier.classifyCategory('gengar-gmax', id: 10198),
        PokemonFormCategory.gmax,
      );
      expect(
        PokemonFormClassifier.classifyCategory('deoxys-attack', id: 10001),
        PokemonFormCategory.battleMode,
      );
      expect(
        PokemonFormClassifier.classifyCategory('rotom-wash', id: 10008),
        PokemonFormCategory.battleMode,
      );
      expect(
        PokemonFormClassifier.classifyCategory(
          'pikachu-original-cap',
          id: 10094,
        ),
        PokemonFormCategory.cosmetic,
      );
      expect(
        PokemonFormClassifier.classifyCategory(
          'mimikyu-totem-disguised',
          id: 10144,
        ),
        PokemonFormCategory.cosmetic,
      );
      expect(
        PokemonFormClassifier.classifyCategory('bulbasaur', id: 1),
        PokemonFormCategory.canonical,
      );
      expect(
        PokemonFormClassifier.classifyCategory('pecharunt', id: 1025),
        PokemonFormCategory.canonical,
      );
      expect(
        PokemonFormClassifier.classifyCategory('bulbasaur'),
        PokemonFormCategory.canonical,
      );
      expect(
        PokemonFormClassifier.classifyCategory('pecharunt'),
        PokemonFormCategory.canonical,
      );
    });

    test('resolves regional groups correctly', () {
      expect(
        PokemonFormClassifier.resolveRegionalGroup('vulpix-alola'),
        PokemonRegionalGroup.alola,
      );
      expect(
        PokemonFormClassifier.resolveRegionalGroup('meowth-galar'),
        PokemonRegionalGroup.galar,
      );
      expect(
        PokemonFormClassifier.resolveRegionalGroup('zorua-hisui'),
        PokemonRegionalGroup.hisui,
      );
      expect(
        PokemonFormClassifier.resolveRegionalGroup('wooper-paldea'),
        PokemonRegionalGroup.paldea,
      );
      expect(
        PokemonFormClassifier.resolveRegionalGroup('venusaur-mega'),
        isNull,
      );
    });

    test('resolves parent species ID in O(1) against canonical table', () {
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('charizard-mega-x'),
        6,
      );
      expect(PokemonFormClassifier.resolveParentSpeciesId('venusaur-mega'), 3);
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('kyogre-primal'),
        382,
      );
      expect(PokemonFormClassifier.resolveParentSpeciesId('vulpix-alola'), 37);
      expect(PokemonFormClassifier.resolveParentSpeciesId('meowth-galar'), 52);
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('mr-mime-galar'),
        122,
      );
      expect(PokemonFormClassifier.resolveParentSpeciesId('zorua-hisui'), 570);
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('wooper-paldea'),
        194,
      );
      expect(PokemonFormClassifier.resolveParentSpeciesId('gengar-gmax'), 94);
      expect(PokemonFormClassifier.resolveParentSpeciesId('rotom-wash'), 479);
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('deoxys-attack'),
        386,
      );
      expect(
        PokemonFormClassifier.resolveParentSpeciesId('darmanitan-galar-zen'),
        555,
      );
    });

    test('formats localized display titles in English and Italian', () {
      // Megas
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'charizard-mega-x',
          parentSpeciesName: 'charizard',
          category: PokemonFormCategory.mega,
          languageCode: 'en',
        ),
        'Mega Charizard X',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'charizard-mega-x',
          parentSpeciesName: 'charizard',
          category: PokemonFormCategory.mega,
          languageCode: 'it',
        ),
        'Mega Charizard X',
      );

      // Primals
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'kyogre-primal',
          parentSpeciesName: 'kyogre',
          category: PokemonFormCategory.primal,
          languageCode: 'en',
        ),
        'Primal Kyogre',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'kyogre-primal',
          parentSpeciesName: 'kyogre',
          category: PokemonFormCategory.primal,
          languageCode: 'it',
        ),
        'Archeo Kyogre',
      );

      // Regionals
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'vulpix-alola',
          parentSpeciesName: 'vulpix',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
          languageCode: 'en',
        ),
        'Alolan Vulpix',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'vulpix-alola',
          parentSpeciesName: 'vulpix',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
          languageCode: 'it',
        ),
        'Vulpix di Alola',
      );

      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'meowth-galar',
          parentSpeciesName: 'meowth',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.galar,
          languageCode: 'en',
        ),
        'Galarian Meowth',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'meowth-galar',
          parentSpeciesName: 'meowth',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.galar,
          languageCode: 'it',
        ),
        'Meowth di Galar',
      );

      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'zorua-hisui',
          parentSpeciesName: 'zorua',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.hisui,
          languageCode: 'en',
        ),
        'Hisuian Zorua',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'zorua-hisui',
          parentSpeciesName: 'zorua',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.hisui,
          languageCode: 'it',
        ),
        'Zorua di Hisui',
      );

      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'wooper-paldea',
          parentSpeciesName: 'wooper',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.paldea,
          languageCode: 'en',
        ),
        'Paldean Wooper',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'wooper-paldea',
          parentSpeciesName: 'wooper',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.paldea,
          languageCode: 'it',
        ),
        'Wooper di Paldea',
      );

      // Gigantamax
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'gengar-gmax',
          parentSpeciesName: 'gengar',
          category: PokemonFormCategory.gmax,
          languageCode: 'en',
        ),
        'Gigantamax Gengar',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'gengar-gmax',
          parentSpeciesName: 'gengar',
          category: PokemonFormCategory.gmax,
          languageCode: 'it',
        ),
        'Gengar Gigamax',
      );

      // Rotom battle modes
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'rotom-wash',
          parentSpeciesName: 'rotom',
          category: PokemonFormCategory.battleMode,
          languageCode: 'en',
        ),
        'Rotom (Wash)',
      );
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'rotom-wash',
          parentSpeciesName: 'rotom',
          category: PokemonFormCategory.battleMode,
          languageCode: 'it',
        ),
        'Rotom (Lavaggio)',
      );

      // Special species display name formatting
      expect(
        PokemonFormClassifier.formatDisplayName(
          name: 'mr-mime',
          parentSpeciesName: 'mr-mime',
          category: PokemonFormCategory.canonical,
          languageCode: 'en',
        ),
        'Mr. Mime',
      );
    });

    test('verifies dual generation bounds mapping', () {
      // Mega Evolution: Gen 1 parent, debuted in Gen 6
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'venusaur-mega',
          category: PokemonFormCategory.mega,
          parentSpeciesId: 3,
        ),
        6,
      );

      // Alolan: Gen 1 parent, debuted in Gen 7
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'vulpix-alola',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.alola,
          parentSpeciesId: 37,
        ),
        7,
      );

      // Galarian: Gen 1 parent, debuted in Gen 8
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'meowth-galar',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.galar,
          parentSpeciesId: 52,
        ),
        8,
      );

      // Hisuian: Gen 5 parent, debuted in Gen 8
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'zorua-hisui',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.hisui,
          parentSpeciesId: 570,
        ),
        8,
      );

      // Paldean: Gen 2 parent, debuted in Gen 9
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'wooper-paldea',
          category: PokemonFormCategory.regional,
          regionalGroup: PokemonRegionalGroup.paldea,
          parentSpeciesId: 194,
        ),
        9,
      );

      // G-Max: Gen 1 parent, debuted in Gen 8
      expect(
        PokemonFormClassifier.resolveIntroductionGeneration(
          name: 'gengar-gmax',
          category: PokemonFormCategory.gmax,
          parentSpeciesId: 94,
        ),
        8,
      );
    });

    test(
      'enrichEntries sets parent references and hasAlternateForms correctly',
      () {
        final rawEntries = [
          const PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
          const PokemonIndexEntry(id: 3, name: 'venusaur', detailUrl: ''),
          const PokemonIndexEntry(
            id: 10033,
            name: 'venusaur-mega',
            detailUrl: '',
          ),
          const PokemonIndexEntry(
            id: 10195,
            name: 'venusaur-gmax',
            detailUrl: '',
          ),
          const PokemonIndexEntry(id: 37, name: 'vulpix', detailUrl: ''),
          const PokemonIndexEntry(
            id: 10103,
            name: 'vulpix-alola',
            detailUrl: '',
          ),
        ];

        final enriched = PokemonFormClassifier.enrichEntries(rawEntries);

        final bulbasaur = enriched.firstWhere((e) => e.id == 1);
        expect(bulbasaur.hasAlternateForms, isFalse);
        expect(bulbasaur.availableFormCategories, isEmpty);

        final venusaur = enriched.firstWhere((e) => e.id == 3);
        expect(venusaur.hasAlternateForms, isTrue);
        expect(
          venusaur.availableFormCategories,
          containsAll([PokemonFormCategory.mega, PokemonFormCategory.gmax]),
        );

        final megaVenusaur = enriched.firstWhere((e) => e.id == 10033);
        expect(megaVenusaur.parentSpeciesId, 3);
        expect(megaVenusaur.parentSpeciesName, 'venusaur');
        expect(megaVenusaur.formCategory, PokemonFormCategory.mega);
        expect(megaVenusaur.isAlternateForm, isTrue);
        expect(megaVenusaur.dexNumberDisplay, '#0003');
        expect(megaVenusaur.displayName, 'Mega Venusaur');
        expect(megaVenusaur.formBadgeText, 'MEGA');
        expect(megaVenusaur.effectiveSpeciesGeneration, 1);
        expect(megaVenusaur.effectiveIntroductionGeneration, 6);

        final vulpixAlola = enriched.firstWhere((e) => e.id == 10103);
        expect(vulpixAlola.parentSpeciesId, 37);
        expect(vulpixAlola.parentSpeciesName, 'vulpix');
        expect(vulpixAlola.regionalGroup, PokemonRegionalGroup.alola);
        expect(vulpixAlola.dexNumberDisplay, '#0037');
        expect(vulpixAlola.displayName, 'Alolan Vulpix');
        expect(vulpixAlola.formBadgeText, 'ALOLA');
        expect(
          vulpixAlola.getDisplayName(languageCode: 'it'),
          'Vulpix di Alola',
        );
      },
    );
  });
}
