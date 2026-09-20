import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/cry_play_button.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_chip.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

void main() {
  setUpAll(() async {
    await configureDependencies('mock');
  });

  Future<void> pumpDetailApp(
    WidgetTester tester, {
    Size? physicalSize,
    double? textScaleFactor,
    String pokemon = 'bulbasaur',
  }) async {
    if (physicalSize != null) {
      tester.view.physicalSize = physicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    await mockNetworkImagesFor(() async {
      final router = createAppRouter(initialLocation: '/pokemon/$pokemon');
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            if (textScaleFactor != null) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
                child: child!,
              );
            }
            return child!;
          },
        ),
      );
      await tester.pumpAndSettle();
    });
  }

  group('Responsive Detail Page', () {
    final viewports = <String, Size>{
      'compact phone (320x568)': const Size(320, 568),
      'standard phone (390x844)': const Size(390, 844),
      'landscape phone (844x390)': const Size(844, 390),
      'tablet (768x1024)': const Size(768, 1024),
    };

    for (final entry in viewports.entries) {
      testWidgets('renders without overflow on ${entry.key}', (tester) async {
        await pumpDetailApp(tester, physicalSize: entry.value);

        expect(tester.takeException(), isNull);
        expect(find.byType(Detail), findsOneWidget);
        expect(find.byType(DetailHeader), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
      });
    }

    testWidgets(
      'renders without overflow at 2.0 text scale factor across all tabs',
      (tester) async {
        await pumpDetailApp(
          tester,
          physicalSize: const Size(390, 844),
          textScaleFactor: 2.0,
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(Detail), findsOneWidget);
        expect(find.byType(DetailHeader), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        for (final tabTitle in ['Stats', 'Moves', 'Items & Games']) {
          final tabFinder = find.text(tabTitle);
          await tester.tap(tabFinder, warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'Stats tab renders without overflow at 2.0 text scale factor on compact phone (320x568)',
      (tester) async {
        await pumpDetailApp(
          tester,
          physicalSize: const Size(320, 568),
          textScaleFactor: 2.0,
        );

        await tester.tap(find.text('Stats'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('tab bar is scrollable to prevent high-scale tab truncation', (
      tester,
    ) async {
      await pumpDetailApp(tester);

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, isTrue);
    });

    testWidgets('landscape orientation uses side-by-side Row layout', (
      tester,
    ) async {
      await pumpDetailApp(tester, physicalSize: const Size(844, 390));

      final orientationBuilderFinder = find.byType(OrientationBuilder);
      expect(orientationBuilderFinder, findsOneWidget);

      expect(
        find.descendant(
          of: orientationBuilderFinder,
          matching: find.byType(Row),
        ),
        findsWidgets,
      );
    });
  });

  group('Detail Accessibility & Semantics', () {
    testWidgets('header and sprite provide explicit semantics announcements', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpDetailApp(tester);

        expect(find.bySemanticsLabel('Bulbasaur, #001'), findsOneWidget);

        expect(
          find.bySemanticsLabel('Bulbasaur, Default Form'),
          findsOneWidget,
        );

        // Toggle shiny mode via shiny toggle button in AppBar
        final shinyToggleFinder = find.byTooltip('Toggle Shiny View');
        expect(shinyToggleFinder, findsOneWidget);

        await tester.tap(shinyToggleFinder);
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Bulbasaur, Shiny Version'),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('cry play button announces localized accessible label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpDetailApp(tester);

        final cryFinder = find.byType(CryPlayButton).first;
        await tester.ensureVisible(cryFinder);
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Latest: Play cry for bulbasaur'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Legacy: Play cry for bulbasaur'),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('base stat rows announce stat name, value, min and max', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpDetailApp(tester);

        // Switch to Stats tab (tab index 1)
        await tester.tap(find.text('Stats'));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('HP: 45, min 200, max 294'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Attack: 49, min 92, max 216'),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('touch targets meet minimum 48x48 dp requirement', (
      tester,
    ) async {
      await pumpDetailApp(tester);

      // Back button
      final backButtonFinder = find.byType(BackButton);
      expect(backButtonFinder, findsOneWidget);
      final backSize = tester.getSize(backButtonFinder);
      expect(backSize.width, greaterThanOrEqualTo(48.0));
      expect(backSize.height, greaterThanOrEqualTo(48.0));

      // Shiny toggle button
      final shinyButtonFinder = find.byTooltip('Toggle Shiny View');
      expect(shinyButtonFinder, findsOneWidget);
      final shinySize = tester.getSize(shinyButtonFinder);
      expect(shinySize.width, greaterThanOrEqualTo(48.0));
      expect(shinySize.height, greaterThanOrEqualTo(48.0));

      // Cry play button
      final cryButtonFinder = find.byType(CryPlayButton).first;
      expect(cryButtonFinder, findsOneWidget);
      final crySize = tester.getSize(cryButtonFinder);
      expect(crySize.width, greaterThanOrEqualTo(48.0));
      expect(crySize.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('TypeChip fallback & localization', () {
    testWidgets('renders localized text chip when image url is null', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TypeChip(type: PokemonType.grass, imageUrl: null),
            ),
          ),
        );

        expect(find.text('Grass'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(find.bySemanticsLabel('Grass'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('renders localized text chip when image url is empty', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TypeChip(type: PokemonType.fire, imageUrl: ''),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fire'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
        expect(find.bySemanticsLabel('Fire'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
      'renders localized text chip on image load failure at 2.0 text scale',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final originalProvider = debugNetworkImageHttpClientProvider;
        debugNetworkImageHttpClientProvider = () => _FailingHttpClient();
        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: const Scaffold(
                  body: TypeChip(
                    type: PokemonType.fighting,
                    imageUrl: 'https://invalid.url/fighting.png',
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Fighting'), findsOneWidget);
          expect(find.bySemanticsLabel('Fighting'), findsOneWidget);
        } finally {
          debugNetworkImageHttpClientProvider = originalProvider;
          semantics.dispose();
        }
      },
    );

    testWidgets('resets error state when type changes with same image url', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final originalProvider = debugNetworkImageHttpClientProvider;
        debugNetworkImageHttpClientProvider = () => _FailingHttpClient();

        try {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();

          await tester.pumpWidget(
            const MaterialApp(
              locale: Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: TypeChip(
                  type: PokemonType.fighting,
                  imageUrl: 'https://example.com/badge.png',
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Fighting'), findsOneWidget);

          // Restore working mock and rebuild with different type but identical image URL
          debugNetworkImageHttpClientProvider = originalProvider;
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();

          await tester.pumpWidget(
            const MaterialApp(
              locale: Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: TypeChip(
                  type: PokemonType.water,
                  imageUrl: 'https://example.com/badge.png',
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(Image), findsOneWidget);
          expect(find.text('Water'), findsNothing);
        } finally {
          debugNetworkImageHttpClientProvider = originalProvider;
        }
      });
    });
  });
}

class _FailingHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    throw const SocketException('offline');
  }
}
