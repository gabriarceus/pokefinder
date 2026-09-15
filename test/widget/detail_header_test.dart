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
  String typeImage1 = '',
  String typeImage2 = '',
}) {
  return DetailHeader(
    selectedFormName: 'bulbasaur',
    pokemonId: 1,
    typeImage1: typeImage1,
    typeImage2: typeImage2,
    textColor: Colors.black,
    spriteWidget: const SizedBox(width: 10, height: 10),
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
    await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

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
