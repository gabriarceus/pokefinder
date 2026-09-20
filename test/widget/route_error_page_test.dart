import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';

void main() {
  group('RouteErrorPage', () {
    testWidgets('renders title, error message, and home action button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const RouteErrorPage(
            rawParam: 'invalid!param',
            errorMessage: 'Invalid Pokémon route parameter.',
          ),
        ),
      );

      expect(
        find.text('Page Not Found'),
        findsNWidgets(2),
      ); // AppBar and headline
      expect(find.text('Invalid Pokémon route parameter.'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Go to Home'), findsOneWidget);
    });

    testWidgets('renders Italian localization correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: RouteErrorPage(),
        ),
      );

      expect(find.text('Pagina non trovata'), findsNWidgets(2));
      expect(find.text('Torna alla Home'), findsOneWidget);
    });

    testWidgets('home button remains hittable on compact screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/error',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/error',
            builder: (_, _) => const RouteErrorPage(
              rawParam: 'unknown',
              errorMessage: 'Not found',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
