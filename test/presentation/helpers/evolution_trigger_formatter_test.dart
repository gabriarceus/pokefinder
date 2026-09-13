import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/helpers/evolution_trigger_formatter.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';

void main() {
  group('EvolutionTriggerFormatter', () {
    test('formats min level', () {
      const detail = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 16,
      );
      expect(EvolutionTriggerFormatter.format(detail), 'Lv. 16');
    });

    test('formats item usage without and with gender and time constraints', () {
      const waterStone = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'water-stone',
      );
      expect(EvolutionTriggerFormatter.format(waterStone), 'Use Water Stone');

      const dawnStoneMale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'dawn-stone',
        gender: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneMale),
        'Use Dawn Stone (Male)',
      );

      const dawnStoneFemale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'dawn-stone',
        gender: 1,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneFemale),
        'Use Dawn Stone (Female)',
      );

      const sunStoneDay = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'sun-stone',
        timeOfDay: 'day',
      );
      expect(
        EvolutionTriggerFormatter.format(sunStoneDay),
        'Use Sun Stone (Day)',
      );

      const moonStoneNight = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'moon-stone',
        timeOfDay: 'night',
      );
      expect(
        EvolutionTriggerFormatter.format(moonStoneNight),
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
          EvolutionTriggerFormatter.format(razorFangNight),
          'Hold Razor Fang (Night)',
        );

        const ovalStoneDay = EvolutionTriggerDetail(
          triggerType: EvolutionTriggerType.levelUp,
          heldItem: 'oval-stone',
          timeOfDay: 'day',
        );
        expect(
          EvolutionTriggerFormatter.format(ovalStoneDay),
          'Hold Oval Stone (Day)',
        );

        const heldItemOnly = EvolutionTriggerDetail(
          triggerType: EvolutionTriggerType.levelUp,
          heldItem: 'deep-sea-scale',
        );
        expect(
          EvolutionTriggerFormatter.format(heldItemOnly),
          'Hold Deep Sea Scale',
        );
      },
    );

    test('formats trade with and without held item or trade species', () {
      const tradeSimple = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
      );
      expect(EvolutionTriggerFormatter.format(tradeSimple), 'Trade');

      const tradeItem = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
        heldItem: 'metal-coat',
      );
      expect(
        EvolutionTriggerFormatter.format(tradeItem),
        'Trade holding Metal Coat',
      );

      const tradeFor = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.trade,
        tradeSpecies: 'shelmet',
      );
      expect(EvolutionTriggerFormatter.format(tradeFor), 'Trade for Shelmet');
    });

    test('formats happiness triggers with time of day', () {
      const dayHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 160,
        timeOfDay: 'day',
      );
      expect(
        EvolutionTriggerFormatter.format(dayHappiness),
        'Friendship (Day)',
      );

      const nightHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 160,
        timeOfDay: 'night',
      );
      expect(
        EvolutionTriggerFormatter.format(nightHappiness),
        'Friendship (Night)',
      );

      const simpleHappiness = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minHappiness: 220,
      );
      expect(
        EvolutionTriggerFormatter.format(simpleHappiness),
        'High Friendship',
      );
    });

    test('formats affection and beauty triggers (e.g. Sylveon, Milotic)', () {
      const affection = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minAffection: 2,
      );
      expect(EvolutionTriggerFormatter.format(affection), 'High Affection');

      const beauty = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minBeauty: 170,
      );
      expect(EvolutionTriggerFormatter.format(beauty), 'High Beauty');
    });

    test('formats location triggers', () {
      const location = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        location: 'eterna-forest',
      );
      expect(
        EvolutionTriggerFormatter.format(location),
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
        EvolutionTriggerFormatter.format(withLevel),
        'Lv. 30 (Upside down)',
      );

      const withoutLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        turnUpsideDown: true,
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevel),
        'Turn device upside down',
      );
    });

    test('formats rain evolution (e.g. Sliggoo)', () {
      const withLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 50,
        needsRain: true,
      );
      expect(EvolutionTriggerFormatter.format(withLevel), 'Lv. 50 (Rain)');

      const withoutLevel = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        needsRain: true,
      );
      expect(EvolutionTriggerFormatter.format(withoutLevel), 'Rain');
    });

    test('formats stat-dependent evolutions (e.g. Tyrogue)', () {
      const atkGtDef = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: 1,
      );
      expect(EvolutionTriggerFormatter.format(atkGtDef), 'Lv. 20 (Atk > Def)');

      const defGtAtk = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: -1,
      );
      expect(EvolutionTriggerFormatter.format(defGtAtk), 'Lv. 20 (Def > Atk)');

      const atkEqDef = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        relativePhysicalStats: 0,
      );
      expect(EvolutionTriggerFormatter.format(atkEqDef), 'Lv. 20 (Atk = Def)');
    });

    test('formats party species and party type evolution', () {
      const withLevelSpecies = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 30,
        partySpecies: 'remoraid',
      );
      expect(
        EvolutionTriggerFormatter.format(withLevelSpecies),
        'Lv. 30 (with Remoraid)',
      );

      const withoutLevelSpecies = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        partySpecies: 'remoraid',
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevelSpecies),
        'With Remoraid',
      );

      const withLevelType = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 32,
        partyType: 'dark',
      );
      expect(
        EvolutionTriggerFormatter.format(withLevelType),
        'Lv. 32 (Dark in party)',
      );

      const withoutLevelType = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        partyType: 'dark',
      );
      expect(
        EvolutionTriggerFormatter.format(withoutLevelType),
        'Dark in party',
      );
    });

    test('formats gender-specific evolution (e.g. Combee, Salandit)', () {
      const female = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 21,
        gender: 1,
      );
      expect(EvolutionTriggerFormatter.format(female), 'Lv. 21 (Female)');

      const male = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        minLevel: 20,
        gender: 2,
      );
      expect(EvolutionTriggerFormatter.format(male), 'Lv. 20 (Male)');

      const femaleAlone = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.other,
        gender: 1,
      );
      expect(EvolutionTriggerFormatter.format(femaleAlone), 'Female');
    });

    test('formats shed trigger (e.g. Shedinja)', () {
      const shed = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.shed,
      );
      expect(EvolutionTriggerFormatter.format(shed), 'Empty slot & Poké Ball');
    });

    testWidgets('formats with Italian localization', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      const dawnStoneMale = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.useItem,
        item: 'pietra-aurora',
        gender: 2,
      );
      expect(
        EvolutionTriggerFormatter.format(dawnStoneMale, l10n: l10n),
        'Usa Pietra Aurora (Maschio)',
      );

      const razorFangNight = EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.levelUp,
        heldItem: 'affilodente',
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
