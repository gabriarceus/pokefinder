import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/helpers/evolution_trigger_formatter.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('EvolutionTriggerFormatter', () {
    final enL10n = lookupAppLocalizations(const Locale('en'));

    test('formats min level', () {
      const detail = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 16,
      );
      expect(EvolutionTriggerFormatter.format(detail, l10n: enL10n), 'Lv. 16');
    });

    test('formats item usage without and with gender and time constraints', () {
      const waterStone = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'water-stone',
      );
      expect(
        EvolutionTriggerFormatter.format(waterStone, l10n: enL10n),
        'Use Water Stone',
      );

      const dawnStoneMale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'dawn-stone',
        gender: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneMale, l10n: enL10n),
        'Use Dawn Stone (Male)',
      );

      const dawnStoneFemale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'dawn-stone',
        gender: 1,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneFemale, l10n: enL10n),
        'Use Dawn Stone (Female)',
      );

      const sunStoneDay = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'sun-stone',
        timeOfDay: 'day',
      );
      expect(
        EvolutionTriggerFormatter.format(sunStoneDay, l10n: enL10n),
        'Use Sun Stone (Day)',
      );

      const moonStoneNight = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'moon-stone',
        timeOfDay: 'night',
      );
      expect(
        EvolutionTriggerFormatter.format(moonStoneNight, l10n: enL10n),
        'Use Moon Stone (Night)',
      );
    });

    test(
      'formats held item triggers with time of day (e.g. Gliscor, Sneasel)',
      () {
        const razorFangNight = EvolutionTriggerDetail(
          triggerType: EvolutionTriggerType.levelUp,
          heldItem: 'razor-fang',
          timeOfDay: 'night',
        );
        expect(
          EvolutionTriggerFormatter.format(razorFangNight, l10n: enL10n),
          'Hold Razor Fang (Night)',
        );

        const ovalStoneDay = EvolutionTriggerDetail(
          triggerType: EvolutionTriggerType.levelUp,
          heldItem: 'oval-stone',
          timeOfDay: 'day',
        );
        expect(
          EvolutionTriggerFormatter.format(ovalStoneDay, l10n: enL10n),
          'Hold Oval Stone (Day)',
        );

        const heldItemOnly = EvolutionTriggerDetail(
          triggerType: EvolutionTriggerType.levelUp,
          heldItem: 'deep-sea-scale',
        );
        expect(
          EvolutionTriggerFormatter.format(heldItemOnly, l10n: enL10n),
          'Hold Deep Sea Scale',
        );
      },
    );

    test('formats trade with and without held item or trade species', () {
      const tradeSimple = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
      );
      expect(
        EvolutionTriggerFormatter.format(tradeSimple, l10n: enL10n),
        'Trade',
      );

      const tradeItem = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
        heldItem: 'metal-coat',
      );
      expect(
        EvolutionTriggerFormatter.format(tradeItem, l10n: enL10n),
        'Trade holding Metal Coat',
      );

      const tradeFor = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
        tradeSpecies: 'shelmet',
      );
      expect(
        EvolutionTriggerFormatter.format(tradeFor, l10n: enL10n),
        'Trade for Shelmet',
      );
    });

    test('formats happiness triggers with time of day', () {
      const dayHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 160,
        timeOfDay: 'day',
      );
      expect(
        EvolutionTriggerFormatter.format(dayHappiness, l10n: enL10n),
        'Friendship (Day)',
      );

      const nightHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 160,
        timeOfDay: 'night',
      );
      expect(
        EvolutionTriggerFormatter.format(nightHappiness, l10n: enL10n),
        'Friendship (Night)',
      );

      const simpleHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 220,
      );
      expect(
        EvolutionTriggerFormatter.format(simpleHappiness, l10n: enL10n),
        'High Friendship',
      );
    });

    test('formats affection and beauty triggers (e.g. Sylveon, Milotic)', () {
      const affection = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minAffection: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(affection, l10n: enL10n),
        'High Affection',
      );

      const beauty = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minBeauty: 170,
      );
      expect(
        EvolutionTriggerFormatter.format(beauty, l10n: enL10n),
        'High Beauty',
      );
    });

    test('formats location triggers', () {
      const location = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        location: 'eterna-forest',
      );
      expect(
        EvolutionTriggerFormatter.format(location, l10n: enL10n),
        'Level up at Eterna Forest',
      );
    });

    test('formats upside down evolution (e.g. Malamar)', () {
      const withLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 30,
        turnUpsideDown: true,
      );
      expect(
        EvolutionTriggerFormatter.format(withLevel, l10n: enL10n),
        'Lv. 30 (Upside down)',
      );

      const withoutLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        turnUpsideDown: true,
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevel, l10n: enL10n),
        'Turn device upside down',
      );
    });

    test('formats rain evolution (e.g. Sliggoo)', () {
      const withLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 50,
        needsRain: true,
      );
      expect(
        EvolutionTriggerFormatter.format(withLevel, l10n: enL10n),
        'Lv. 50 (Rain)',
      );

      const withoutLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        needsRain: true,
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevel, l10n: enL10n),
        'Rain',
      );
    });

    test('formats stat-dependent evolutions (e.g. Tyrogue)', () {
      const atkGtDef = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: 1,
      );
      expect(
        EvolutionTriggerFormatter.format(atkGtDef, l10n: enL10n),
        'Lv. 20 (Atk > Def)',
      );

      const defGtAtk = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: -1,
      );
      expect(
        EvolutionTriggerFormatter.format(defGtAtk, l10n: enL10n),
        'Lv. 20 (Def > Atk)',
      );

      const atkEqDef = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: 0,
      );
      expect(
        EvolutionTriggerFormatter.format(atkEqDef, l10n: enL10n),
        'Lv. 20 (Atk = Def)',
      );
    });

    test('formats party species and party type evolution', () {
      const withLevelSpecies = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 30,
        partySpecies: 'remoraid',
      );
      expect(
        EvolutionTriggerFormatter.format(withLevelSpecies, l10n: enL10n),
        'Lv. 30 (with Remoraid)',
      );

      const withoutLevelSpecies = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        partySpecies: 'remoraid',
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevelSpecies, l10n: enL10n),
        'With Remoraid',
      );

      const withLevelType = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 32,
        partyType: 'dark',
      );
      expect(
        EvolutionTriggerFormatter.format(withLevelType, l10n: enL10n),
        'Lv. 32 (Dark in party)',
      );

      const withoutLevelType = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        partyType: 'dark',
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevelType, l10n: enL10n),
        'Dark in party',
      );
    });

    test('formats gender-specific evolution (e.g. Combee, Salandit)', () {
      const female = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 21,
        gender: 1,
      );
      expect(
        EvolutionTriggerFormatter.format(female, l10n: enL10n),
        'Lv. 21 (Female)',
      );

      const male = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        gender: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(male, l10n: enL10n),
        'Lv. 20 (Male)',
      );

      const femaleAlone = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        gender: 1,
      );
      expect(
        EvolutionTriggerFormatter.format(femaleAlone, l10n: enL10n),
        'Female',
      );
    });

    test('formats shed trigger (e.g. Shedinja)', () {
      const shed = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.shed,
      );
      expect(
        EvolutionTriggerFormatter.format(shed, l10n: enL10n),
        'Empty slot & Poké Ball',
      );
    });

    testWidgets('formats with Italian localization', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpApp(
        locale: const Locale('it'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      const dawnStoneMale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'dawn-stone',
        gender: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneMale, l10n: l10n),
        'Usa Pietralbore (Maschio)',
      );

      const razorFangNight = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        heldItem: 'razor-fang',
        timeOfDay: 'night',
      );
      expect(
        EvolutionTriggerFormatter.format(razorFangNight, l10n: l10n),
        'Tiene Affilodente (Notte)',
      );

      const mantykeParty = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        partySpecies: 'remoraid',
      );
      expect(
        EvolutionTriggerFormatter.format(mantykeParty, l10n: l10n),
        'Con Remoraid',
      );

      const affection = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minAffection: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(affection, l10n: l10n),
        'Affetto elevato',
      );

      const beauty = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minBeauty: 170,
      );
      expect(
        EvolutionTriggerFormatter.format(beauty, l10n: l10n),
        'Bellezza elevata',
      );
    });
  });
}
