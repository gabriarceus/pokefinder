import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';

void main() {
  group('TranslationExtension Tests', () {
    Widget buildTestWidget({
      required Locale locale,
      required Widget Function(BuildContext context) builder,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(
          body: Builder(builder: builder),
        ),
      );
    }

    testWidgets('Translates abilities to Italian and falls back to default formatting in English', (tester) async {
      // Italian Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateAbility('skill-link'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Abillegame'), findsOneWidget);

      // English Locale (should format default)
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateAbility('skill-link'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Skill Link'), findsOneWidget);
    });

    testWidgets('Translates moves to Italian and falls back to default formatting in English', (tester) async {
      // Italian Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateMove('skill-swap'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Baratto'), findsOneWidget);

      // English Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateMove('skill-swap'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Skill Swap'), findsOneWidget);
    });

    testWidgets('Translates location routes to Italian', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateLocation('kanto-route-1-area'));
          },
        ),
      );
      await tester.pumpAndSettle();
      // Let's assert the exact string returned currently
      expect(find.text('Percorso 1 (Kanto) area'), findsOneWidget);
    });

    testWidgets('Translates non-route locations using database lookup in Italian', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateLocation('abandoned-ship'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Vecchia Nave'), findsOneWidget);
    });

    testWidgets('Translates game versions using AppLocalizations', (tester) async {
      // Italian Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateGameVersion('omega-ruby-alpha-sapphire'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Rubino Omega/Zaffiro Alpha'), findsOneWidget);

      // English Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateGameVersion('omega-ruby-alpha-sapphire'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Omega Ruby/Alpha Sapphire'), findsOneWidget);
    });

    testWidgets('Translates types using AppLocalizations', (tester) async {
      // Italian Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) {
            return Text(context.translateType('fire'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fuoco'), findsOneWidget);

      // English Locale
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) {
            return Text(context.translateType('fire'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fire'), findsOneWidget);
    });
  });
}
