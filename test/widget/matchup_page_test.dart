import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/matchups/matchup_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('parseMatchupTypesParam', () {
    test('returns empty for null, blank, or unknown slugs', () {
      expect(parseMatchupTypesParam(null), isEmpty);
      expect(parseMatchupTypesParam(''), isEmpty);
      expect(parseMatchupTypesParam('  '), isEmpty);
      expect(parseMatchupTypesParam('mystery-xyz'), isEmpty);
    });

    test('parses one or two battle types', () {
      expect(parseMatchupTypesParam('fire'), equals([PokemonType.fire]));
      expect(
        parseMatchupTypesParam('fire,flying'),
        equals([PokemonType.fire, PokemonType.flying]),
      );
    });

    test('drops stellar, duplicates, and extras beyond two', () {
      expect(parseMatchupTypesParam('stellar'), isEmpty);
      expect(parseMatchupTypesParam('fire,fire'), equals([PokemonType.fire]));
      expect(
        parseMatchupTypesParam('fire,flying,water'),
        equals([PokemonType.fire, PokemonType.flying]),
      );
      expect(
        parseMatchupTypesParam(' fire , FLYING '),
        equals([PokemonType.fire, PokemonType.flying]),
      );
    });
  });

  group('buildMatchupPath', () {
    test('returns base path when empty', () {
      expect(buildMatchupPath(const []), equals('/matchups'));
    });

    test('encodes one or two slugs', () {
      expect(
        buildMatchupPath(const [PokemonType.fire]),
        equals('/matchups?types=fire'),
      );
      expect(
        buildMatchupPath(const [PokemonType.fire, PokemonType.flying]),
        equals('/matchups?types=fire,flying'),
      );
    });
  });

  group('MatchupPage empty state', () {
    testWidgets('shows empty title and message when nothing selected', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MatchupPage()));
      await tester.pumpAndSettle();

      expect(find.text('Type matchups'), findsOneWidget);
      expect(find.text('Defending types'), findsOneWidget);
      expect(find.text('No defending type selected'), findsOneWidget);
      expect(
        find.text(
          'Select 1 or 2 defending types to see weaknesses, resistances and immunities.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('localizes empty state in Italian', (tester) async {
      await tester.pumpWidget(
        _wrap(const MatchupPage(), locale: const Locale('it')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Affinità di tipo'), findsOneWidget);
      expect(find.text('Nessun tipo in difesa'), findsOneWidget);
    });
  });

  group('MatchupPage selection and result groups', () {
    testWidgets('selecting a type shows weak and resistant groups', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const MatchupPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Fire'));
      await tester.pumpAndSettle();

      // Result groups announce via semantics labels.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('2× weak to:'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('½× resistant to:'),
        ),
        findsOneWidget,
      );
      // Fire defending is weak to Water/Ground/Rock.
      final weakGroup = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('2× weak to:'),
        ),
      );
      expect(weakGroup.properties.label, contains('Water'));
      expect(find.text('Clear selection'), findsOneWidget);
    });

    testWidgets('dual selection shows the 4x group', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MatchupPage(
            initialDefending: [PokemonType.fire, PokemonType.flying],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final quad = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            (w.properties.label ?? '').startsWith('4× weak to:'),
      );
      expect(quad, findsOneWidget);
      expect(tester.widget<Semantics>(quad).properties.label, contains('Rock'));
      // Ground immunity is preserved for Fire/Flying.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('Immune to:'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('preset from detail types announces defending selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const MatchupPage(
            initialDefending: [PokemonType.grass, PokemonType.poison],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Grass, Poison',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a selected type deselects it', (tester) async {
      await tester.pumpWidget(
        _wrap(const MatchupPage(initialDefending: [PokemonType.fire])),
      );
      await tester.pumpAndSettle();

      expect(find.text('No defending type selected'), findsNothing);

      await tester.tap(find.byTooltip('Fire'));
      await tester.pumpAndSettle();

      expect(find.text('No defending type selected'), findsOneWidget);
    });

    testWidgets('clear selection returns to the empty state', (tester) async {
      await tester.pumpWidget(
        _wrap(const MatchupPage(initialDefending: [PokemonType.water])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear selection'));
      await tester.pumpAndSettle();

      expect(find.text('No defending type selected'), findsOneWidget);
    });

    testWidgets('selecting a third type replaces the oldest', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MatchupPage(
            initialDefending: [PokemonType.fire, PokemonType.flying],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Water'));
      await tester.pumpAndSettle();

      // Oldest (Fire) dropped; defending is now Flying + Water.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Flying, Water',
        ),
        findsOneWidget,
      );
    });

    testWidgets('selector meets 48x48 touch targets', (tester) async {
      await tester.pumpWidget(_wrap(const MatchupPage()));
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byTooltip('Fire'));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('stays without overflow on compact phone with 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: _wrap(
            const MatchupPage(
              initialDefending: [PokemonType.fire, PokemonType.flying],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Type matchups'), findsOneWidget);
    });
  });

  group('MatchupPage route', () {
    testWidgets('navigating to /matchups loads MatchupPage', (tester) async {
      final router = createAppRouter(initialLocation: '/matchups');
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MatchupPage), findsOneWidget);
      expect(find.text('Type matchups'), findsOneWidget);
    });

    testWidgets('query preset selects defending types', (tester) async {
      final router = createAppRouter(
        initialLocation: '/matchups?types=fire,flying',
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MatchupPage), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('4× weak to:'),
        ),
        findsOneWidget,
      );
    });
  });

  group('MatchupPage chip contrast', () {
    Widget wrapThemed(Widget child, {required bool dark}) {
      final scheme = dark
          ? ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            )
          : ColorScheme.fromSeed(seedColor: Colors.deepPurple);
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(colorScheme: scheme, useMaterial3: true),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(body: child),
      );
    }

    testWidgets('unselected chip text uses onSurface in light theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapThemed(MatchupPage(initialDefending: const []), dark: false),
      );
      await tester.pumpAndSettle();

      final chipText = find.descendant(
        of: find.byTooltip('Ghost'),
        matching: find.text('Ghost'),
      );
      final element = tester.element(chipText);
      final expected = Theme.of(element).colorScheme.onSurface;
      final text = tester.widget<Text>(chipText);
      expect(text.style?.color, expected);
    });

    testWidgets('unselected chip text uses onSurface in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapThemed(MatchupPage(initialDefending: const []), dark: true),
      );
      await tester.pumpAndSettle();

      final chipText = find.descendant(
        of: find.byTooltip('Electric'),
        matching: find.text('Electric'),
      );
      final element = tester.element(chipText);
      final expected = Theme.of(element).colorScheme.onSurface;
      final text = tester.widget<Text>(chipText);
      expect(text.style?.color, expected);
    });

    testWidgets('selected chip text uses contrasting color', (tester) async {
      await tester.pumpWidget(
        wrapThemed(
          MatchupPage(initialDefending: const [PokemonType.fire]),
          dark: false,
        ),
      );
      await tester.pumpAndSettle();

      final chipText = find.descendant(
        of: find.byTooltip('Fire'),
        matching: find.text('Fire'),
      );
      final element = tester.element(chipText);
      final onSurface = Theme.of(element).colorScheme.onSurface;
      final text = tester.widget<Text>(chipText);
      expect(text.style?.color, isNot(equals(onSurface)));
    });
  });

  group('MatchupPage didUpdateWidget', () {
    testWidgets('rebuild with equal list preserves user selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(MatchupPage(initialDefending: [PokemonType.fire])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Flying'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Fire, Flying',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        _wrap(MatchupPage(initialDefending: [PokemonType.fire])),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Fire, Flying',
        ),
        findsOneWidget,
      );
    });

    testWidgets('rebuild with changed list updates selection', (tester) async {
      await tester.pumpWidget(
        _wrap(MatchupPage(initialDefending: [PokemonType.fire])),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        _wrap(
          MatchupPage(
            initialDefending: const [PokemonType.water, PokemonType.grass],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Water, Grass',
        ),
        findsOneWidget,
      );
    });
  });
}
