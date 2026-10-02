import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import '../helpers/pump_app.dart';

void main() {
  group('TranslationExtension Tests', () {
    Future<void> pumpTestWidget(
      WidgetTester tester, {
      required Locale locale,
      required Widget Function(BuildContext context) builder,
    }) {
      return tester.pumpApp(
        locale: locale,
        home: Scaffold(body: Builder(builder: builder)),
      );
    }

    testWidgets(
      'Translates abilities to Italian and falls back to default formatting in English',
      (tester) async {
        // Italian Locale
        await pumpTestWidget(
          tester,
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateAbility('skill-link'));
          },
        );
        await tester.pumpAndSettle();
        expect(find.text('Abillegame'), findsOneWidget);

        // English Locale (should format default)
        await pumpTestWidget(
          tester,
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateAbility('skill-link'));
          },
        );
        await tester.pumpAndSettle();
        expect(find.text('Skill Link'), findsOneWidget);
      },
    );

    testWidgets(
      'Translates moves to Italian and falls back to default formatting in English',
      (tester) async {
        // Italian Locale
        await pumpTestWidget(
          tester,
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateMove('skill-swap'));
          },
        );
        await tester.pumpAndSettle();
        expect(find.text('Baratto'), findsOneWidget);

        // English Locale
        await pumpTestWidget(
          tester,
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateMove('skill-swap'));
          },
        );
        await tester.pumpAndSettle();
        expect(find.text('Skill Swap'), findsOneWidget);
      },
    );

    testWidgets('Translates location routes to Italian', (tester) async {
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) {
          return Text(context.translateLocation('kanto-route-1-area'));
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Percorso 1 (Kanto)'), findsOneWidget);
    });

    testWidgets('Translates Legends Arceus routes to Italian', (tester) async {
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) => Column(
          children: [
            Text(context.translateLocation('hisui-route-1')),
            Text(context.translateLocation('hisui-route-1-area')),
            Text(context.translateLocation('mt-coronet-1f')),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Percorso 1 (Hisui)'), findsNWidgets(2));
      expect(find.text('Monte Corona 1F'), findsOneWidget);
    });

    testWidgets(
      'Falls back to the whole English name when part of a location has no translation',
      (tester) async {
        await pumpTestWidget(
          tester,
          locale: const Locale('it'),
          builder: (context) => Text(
            context.translateLocation(
              'kanto-route-2-south-towards-viridian-city',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Kanto Route 2 South Towards Viridian City'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Drops the area suffix from a translated location', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) =>
            Text(context.translateLocation('trophy-garden-area')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giardino Trofeo'), findsOneWidget);
    });

    testWidgets(
      'Translates non-route locations using database lookup in Italian',
      (tester) async {
        await pumpTestWidget(
          tester,
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateLocation('abandoned-ship'));
          },
        );
        await tester.pumpAndSettle();
        expect(find.text('Vecchia Nave'), findsOneWidget);
      },
    );

    testWidgets('Translates game versions using AppLocalizations', (
      tester,
    ) async {
      // Italian Locale
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) {
          return Text(
            context.translateGameVersion('omega-ruby-alpha-sapphire'),
          );
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Rubino Omega/Zaffiro Alpha'), findsOneWidget);

      // English Locale
      await pumpTestWidget(
        tester,
        locale: const Locale('en'),
        builder: (context) {
          return Text(
            context.translateGameVersion('omega-ruby-alpha-sapphire'),
          );
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Omega Ruby/Alpha Sapphire'), findsOneWidget);
    });

    testWidgets('Translates species generation and habitat slugs', (
      tester,
    ) async {
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) => Column(
          children: [
            Text(context.translateGeneration('generation-iv')),
            Text(context.translateHabitat('waters-edge')),
            Text(context.translateHabitat('outer-space')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gen 4'), findsOneWidget);
      expect(find.text("Riva dell'acqua"), findsOneWidget);
      expect(find.text('Outer Space'), findsOneWidget);
    });

    testWidgets('Translates types using AppLocalizations', (tester) async {
      // Italian Locale
      await pumpTestWidget(
        tester,
        locale: const Locale('it'),
        builder: (context) {
          return Text(context.translateType('fire'));
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Fuoco'), findsOneWidget);

      // English Locale
      await pumpTestWidget(
        tester,
        locale: const Locale('en'),
        builder: (context) {
          return Text(context.translateType('fire'));
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Fire'), findsOneWidget);
    });
  });
}
