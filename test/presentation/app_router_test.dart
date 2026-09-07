import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';

void main() {
  setUpAll(() async {
    await configureDependencies('mock');
  });

  Widget createRouterApp(
    String initialLocation, {
    Locale locale = const Locale('en'),
  }) {
    final router = createAppRouter(initialLocation: initialLocation);
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }

  group('AppRouter canonical routes', () {
    testWidgets('navigating to / loads HomePage', (tester) async {
      await tester.pumpWidget(createRouterApp('/'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('navigating to /pokemon/pikachu resolves to Detail with name', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp('/pokemon/pikachu'));
        await tester.pumpAndSettle();

        expect(find.byType(Detail), findsOneWidget);
        final detailWidget = tester.widget<Detail>(find.byType(Detail));
        expect(detailWidget.pokemonName, equals('pikachu'));
      });
    });

    testWidgets(
      'navigating to /pokemon/25 resolves to Detail with numeric ID',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createRouterApp('/pokemon/25'));
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);
          final detailWidget = tester.widget<Detail>(find.byType(Detail));
          expect(detailWidget.pokemonName, equals('25'));
        });
      },
    );

    testWidgets(
      'navigating to invalid param /pokemon/invalid!param renders RouteErrorPage',
      (tester) async {
        await tester.pumpWidget(createRouterApp('/pokemon/invalid!param'));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorPage), findsOneWidget);
        expect(find.byType(Detail), findsNothing);
      },
    );

    testWidgets(
      'navigating to negative or zero ID /pokemon/0 renders RouteErrorPage',
      (tester) async {
        await tester.pumpWidget(createRouterApp('/pokemon/0'));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorPage), findsOneWidget);
        expect(find.byType(Detail), findsNothing);
      },
    );

    testWidgets('navigating to unknown route renders RouteErrorPage', (
      tester,
    ) async {
      await tester.pumpWidget(createRouterApp('/random_unsupported_path'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsOneWidget);
    });

    testWidgets(
      'navigating to unknown route under Italian locale displays localized error',
      (tester) async {
        await tester.pumpWidget(
          createRouterApp(
            '/random_unsupported_path',
            locale: const Locale('it'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorPage), findsOneWidget);
        expect(find.text('Pagina non trovata'), findsNWidgets(2));
        expect(
          find.text('Il Pokémon o la pagina richiesta non è stata trovata.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping Go to Home from RouteErrorPage navigates to HomePage',
      (tester) async {
        await tester.pumpWidget(createRouterApp('/random_unsupported_path'));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorPage), findsOneWidget);

        await tester.tap(find.text('Go to Home'));
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'returning from detail to home preserves search text and state',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createRouterApp('/'));
          await tester.pumpAndSettle();

          // Type search query and maintain focus
          final textFieldFinder = find.byType(TextField);
          await tester.enterText(textFieldFinder, 'pikachu');
          await tester.pumpAndSettle();

          // Submit search
          await tester.tap(find.text('Search'), warnIfMissed: false);
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);

          // Pop back to home via AppBar back button
          await tester.tap(find.byType(BackButton), warnIfMissed: false);
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          final textField = tester.widget<TextField>(find.byType(TextField));
          expect(textField.controller?.text, equals('pikachu'));
          expect(textField.focusNode?.hasFocus, isTrue);
        });
      },
    );
  });
}
