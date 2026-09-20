import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/about/about_page.dart';

void main() {
  Widget buildAboutPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Future<PackageInfo>? packageInfoFuture,
    Future<bool> Function(Uri url)? urlLauncher,
  }) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: AboutPage(
        packageInfoFuture:
            packageInfoFuture ??
            Future.value(
              PackageInfo(
                appName: 'PokéFinder',
                packageName: 'com.gabriarceus.pokefinder',
                version: '1.0.0-rc1',
                buildNumber: '2',
              ),
            ),
        urlLauncher: urlLauncher,
      ),
    );
  }

  group('AboutPage', () {
    testWidgets('renders app header with version and build number in English', (
      tester,
    ) async {
      await tester.pumpWidget(buildAboutPage(tester));
      await tester.pumpAndSettle();

      expect(find.text('PokéFinder'), findsWidgets);
      expect(find.text('Version 1.0.0-rc1 (Build 2)'), findsOneWidget);
      expect(
        find.text(
          'A lightweight, modern Pokédex app for exploring Pokémon, abilities, moves, and stats.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders PokeAPI attribution and disclaimer', (tester) async {
      await tester.pumpWidget(buildAboutPage(tester));
      await tester.pumpAndSettle();

      expect(find.text('Data Source'), findsOneWidget);
      expect(
        find.text(
          'All Pokémon data, sprites, and assets are sourced from PokeAPI.',
        ),
        findsOneWidget,
      );
      expect(find.text('https://pokeapi.co'), findsOneWidget);
      expect(find.text('Disclaimer'), findsOneWidget);
      expect(
        find.textContaining(
          'PokéFinder is an unofficial, non-commercial fan-made app',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Open Source Licenses and links', (tester) async {
      await tester.pumpWidget(buildAboutPage(tester));
      await tester.pumpAndSettle();

      expect(find.text('Open Source Licenses'), findsWidgets);
      expect(find.text('GitHub Repository'), findsOneWidget);
      expect(find.text('Report an Issue'), findsOneWidget);
      expect(
        find.text('https://github.com/gabriarceus/pokefinder'),
        findsOneWidget,
      );
      expect(
        find.text('https://github.com/gabriarceus/pokefinder/issues'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Open Source Licenses opens LicensePage', (
      tester,
    ) async {
      await tester.pumpWidget(buildAboutPage(tester));
      await tester.pumpAndSettle();

      final licenseTile = find.widgetWithText(ListTile, 'Open Source Licenses');
      expect(licenseTile, findsOneWidget);

      await tester.tap(licenseTile);
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('renders localized content in Italian', (tester) async {
      await tester.pumpWidget(
        buildAboutPage(tester, locale: const Locale('it')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Informazioni su PokéFinder'), findsOneWidget);
      expect(find.text('Versione 1.0.0-rc1 (Build 2)'), findsOneWidget);
      expect(find.text('Fonte dati'), findsOneWidget);
      expect(
        find.text(
          'Tutti i dati, gli sprite e le risorse dei Pokémon provengono da PokeAPI.',
        ),
        findsOneWidget,
      );
      expect(find.text('Dichiarazione di non responsabilità'), findsOneWidget);
      expect(find.text('Licenze open source'), findsWidgets);
      expect(find.text('Repository GitHub'), findsOneWidget);
      expect(find.text('Segnala un problema'), findsOneWidget);
    });

    testWidgets(
      'displays progress indicator while packageInfoFuture is pending',
      (tester) async {
        final completer = Completer<PackageInfo>();
        await tester.pumpWidget(
          buildAboutPage(tester, packageInfoFuture: completer.future),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.textContaining('Version'), findsNothing);

        completer.complete(
          PackageInfo(
            appName: 'PokéFinder',
            packageName: 'com.gabriarceus.pokefinder',
            version: '2.0.0',
            buildNumber: '5',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Version 2.0.0 (Build 5)'), findsOneWidget);
      },
    );

    testWidgets('updates version display when packageInfoFuture changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAboutPage(
          tester,
          packageInfoFuture: Future.value(
            PackageInfo(
              appName: 'PokéFinder',
              packageName: 'com.gabriarceus.pokefinder',
              version: '1.0.0',
              buildNumber: '1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);

      await tester.pumpWidget(
        buildAboutPage(
          tester,
          packageInfoFuture: Future.value(
            PackageInfo(
              appName: 'PokéFinder',
              packageName: 'com.gabriarceus.pokefinder',
              version: '1.1.0',
              buildNumber: '2',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Version 1.1.0 (Build 2)'), findsOneWidget);
    });

    testWidgets('displays snackbar fallback when url launch fails or throws', (
      tester,
    ) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildAboutPage(
          tester,
          urlLauncher: (uri) async {
            callCount++;
            if (callCount == 1) {
              return false;
            }
            throw Exception('Platform error');
          },
        ),
      );
      await tester.pumpAndSettle();

      final pokeApiTile = find.widgetWithText(ListTile, 'https://pokeapi.co');
      expect(pokeApiTile, findsOneWidget);

      await tester.tap(pokeApiTile);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('https://pokeapi.co'), findsWidgets);

      // Dismiss snackbar
      ScaffoldMessenger.of(tester.element(pokeApiTile)).hideCurrentSnackBar();
      await tester.pumpAndSettle();

      // Tap again to exercise the throwing branch
      await tester.tap(pokeApiTile);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
