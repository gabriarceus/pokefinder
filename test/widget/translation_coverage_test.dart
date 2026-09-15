import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/abilities_db.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/items_db.dart';
import 'package:pokefinder/l10n/locations_db.dart';
import 'package:pokefinder/l10n/moves_db.dart';
import 'package:pokefinder/l10n/translation_helper.dart';

/// Coverage contract for bulk slug translations (abilities, moves, items,
/// locations): every rendered key has an EN title-case rendering and either
/// an IT database entry or the explicitly documented title-case fallback.
/// Unknown slugs must never surface as raw hyphenated slugs or ALL-CAPS text.
void main() {
  Widget buildTestWidget({
    required Locale locale,
    required Widget Function(BuildContext context) builder,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: Builder(builder: builder)),
    );
  }

  group('translation database integrity', () {
    test('databases are non-empty', () {
      expect(abilitiesDb, isNotEmpty);
      expect(movesDb, isNotEmpty);
      expect(itemsDb, isNotEmpty);
      expect(locationsDb, isNotEmpty);
    });

    test('keys are canonical API slugs', () {
      final slugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
      for (final entry in [
        ...abilitiesDb.entries,
        ...movesDb.entries,
        ...itemsDb.entries,
        ...locationsDb.entries,
      ]) {
        expect(
          slugPattern.hasMatch(entry.key),
          isTrue,
          reason: 'key "${entry.key}" is not a canonical slug',
        );
        expect(entry.value.trim(), isNotEmpty);
      }
    });

    test('values are display text, never raw slugs in caps', () {
      for (final value in [
        ...abilitiesDb.values,
        ...movesDb.values,
        ...itemsDb.values,
        ...locationsDb.values,
      ]) {
        expect(value.contains('-'), isFalse, reason: '"$value" looks raw');
        expect(
          value,
          isNot(equals(value.toUpperCase())),
          reason: '"$value" must not be ALL-CAPS',
        );
      }
    });
  });

  group('translateItem', () {
    testWidgets('resolves known items in Italian', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('it'),
          builder: (context) => Text(context.translateItem('kings-rock')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Roccia di Re'), findsOneWidget);
    });

    testWidgets('falls back to title case in English', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          locale: const Locale('en'),
          builder: (context) => Text(context.translateItem('kings-rock')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kings Rock'), findsOneWidget);
    });

    testWidgets('unknown slugs fall back to title case, never raw', (
      tester,
    ) async {
      for (final locale in [const Locale('en'), const Locale('it')]) {
        await tester.pumpWidget(
          buildTestWidget(
            locale: locale,
            builder: (context) =>
                Text(context.translateItem('mystery-item-xyz')),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Mystery Item Xyz'), findsOneWidget);
        expect(find.text('mystery-item-xyz'), findsNothing);
        expect(find.text('MYSTERY ITEM XYZ'), findsNothing);
      }
    });
  });

  group('fallback contract for all slug translators', () {
    testWidgets('unknown slugs never render raw or in caps', (tester) async {
      for (final locale in [const Locale('en'), const Locale('it')]) {
        await tester.pumpWidget(
          buildTestWidget(
            locale: locale,
            builder: (context) => Column(
              children: [
                Text(context.translateAbility('mystery-ability-xyz')),
                Text(context.translateMove('mystery-move-xyz')),
                Text(context.translateItem('mystery-item-xyz')),
                Text(context.translateLocation('mystery-location-xyz')),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mystery Ability Xyz'), findsOneWidget);
        expect(find.text('Mystery Move Xyz'), findsOneWidget);
        expect(find.text('Mystery Item Xyz'), findsOneWidget);
        expect(find.text('Mystery Location Xyz'), findsOneWidget);
        expect(find.textContaining('-xyz'), findsNothing);
        expect(find.textContaining('MYSTERY'), findsNothing);
      }
    });
  });
}
