import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/pages/matchups/matchup_page.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

Widget _header({
  PokemonType? type1,
  PokemonType? type2,
  String spriteDefault = 'front.png',
  String spriteShiny = 'front-shiny.png',
}) {
  return DetailHeader(
    selectedFormName: 'bulbasaur',
    pokemonId: 1,
    textColor: Colors.black,
    spriteDefault: spriteDefault,
    spriteShiny: spriteShiny,
    type1: type1,
    type2: type2,
  );
}

GoRouter _routerWithHeader(Widget header) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: header),
      ),
      GoRoute(
        path: '/matchups',
        builder: (context, state) {
          final initial = parseMatchupTypesParam(
            state.uri.queryParameters['types'],
          );
          return MatchupPage(initialDefending: initial);
        },
      ),
    ],
  );
}

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) {
  return mockNetworkImagesFor(() async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    // The sprite images never finish loading under `mockNetworkImagesFor`, so
    // their loading spinner animates forever: pump a bounded number of frames
    // instead of settling.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  });
}

void main() {
  group('DetailHeader matchup entry', () {
    testWidgets('single type chip exposes tooltip and semantics', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        _routerWithHeader(_header(type1: PokemonType.fire)),
      );

      expect(find.byTooltip('View matchups'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Fire, View matchups',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping single chip navigates to preset matchups', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        _routerWithHeader(_header(type1: PokemonType.fire)),
      );

      await tester.tap(find.byTooltip('View matchups'));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.byType(MatchupPage), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Fire',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping dual-type chip preserves both defending types', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        _routerWithHeader(
          _header(type1: PokemonType.grass, type2: PokemonType.poison),
        ),
      );

      expect(find.byTooltip('View matchups'), findsNWidgets(2));

      await tester.tap(find.byTooltip('View matchups').first);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.byType(MatchupPage), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '') == 'Defending types: Grass, Poison',
        ),
        findsOneWidget,
      );
    });
  });
}
