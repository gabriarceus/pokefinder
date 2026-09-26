import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_tab_scroll_view.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/cry_play_button.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_chip.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Pumps frames until [finder] matches.
///
/// `mockNetworkImagesFor` never completes the image request, so the detail
/// header's loading spinner animates forever and `pumpAndSettle` never returns.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Pumps a bounded number of frames so transitions and animations settle.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies(Environment.dev);
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
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<PreferencesCubit>()),
            BlocProvider.value(value: getIt<LanguageCubit>()),
            BlocProvider.value(value: getIt<FavoritesCubit>()),
            BlocProvider.value(value: getIt<RecentHistoryCubit>()),
            BlocProvider.value(value: getIt<ComparisonCubit>()),
            BlocProvider.value(value: getIt<TeamsCubit>()),
          ],
          child: MaterialApp.router(
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
        ),
      );
      // The header only exists once the Pokémon has loaded.
      await pumpUntilFound(tester, find.byType(DetailHeader));
      // Let the tab bodies finish their first layout pass.
      await pumpFrames(tester);
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
        expect(find.byType(PokemonDetailPage), findsOneWidget);
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
        expect(find.byType(PokemonDetailPage), findsOneWidget);
        expect(find.byType(DetailHeader), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        for (final tabTitle in ['Stats', 'Moves', 'Where to find']) {
          final tabFinder = find.text(tabTitle);
          await tester.tap(tabFinder, warnIfMissed: false);
          await pumpFrames(tester);
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
        await pumpFrames(tester);

        expect(tester.takeException(), isNull);
      },
    );
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
        await pumpFrames(tester);

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

        // The cries sit far down the info tab, whose slivers build lazily.
        await tester.dragUntilVisible(
          find.widgetWithText(CryPlayButton, 'Latest'),
          find.byType(DetailTabScrollView).first,
          const Offset(0, -200),
        );
        await pumpFrames(tester);

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
        await pumpFrames(tester);

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

      // Shiny toggle button.
      // Measure the tappable `IconButton`, not the `Tooltip` that IconButton
      // builds internally: the tooltip box is the 40 dp icon box, while the
      // button keeps Material 3's padded 48 dp target.
      final shinyButtonFinder = find.ancestor(
        of: find.byTooltip('Toggle Shiny View'),
        matching: find.byType(IconButton),
      );
      expect(shinyButtonFinder, findsOneWidget);
      final shinySize = tester.getSize(shinyButtonFinder);
      expect(shinySize.width, greaterThanOrEqualTo(48.0));
      expect(shinySize.height, greaterThanOrEqualTo(48.0));

      // Cry play button. The cries sit far down the info tab, whose slivers
      // build lazily, so scroll it into view before measuring it.
      final cryButtonFinder = find.widgetWithText(CryPlayButton, 'Latest');
      await tester.dragUntilVisible(
        cryButtonFinder,
        find.byType(DetailTabScrollView).first,
        const Offset(0, -200),
      );
      await pumpFrames(tester);
      expect(cryButtonFinder, findsOneWidget);
      final crySize = tester.getSize(cryButtonFinder);
      expect(crySize.width, greaterThanOrEqualTo(48.0));
      expect(crySize.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('TypeChip localization', () {
    testWidgets('renders a localized text chip without a type sprite image', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: TypeChip(type: PokemonType.grass)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Grass'), findsOneWidget);
        // Type sprites carry English text, so the chip never renders one.
        expect(find.byType(Image), findsNothing);
        expect(find.bySemanticsLabel('Grass'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('renders a localized text chip at 2.0 text scale', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: const Scaffold(body: TypeChip(type: PokemonType.fighting)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Fighting'), findsOneWidget);
        expect(find.bySemanticsLabel('Fighting'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('rebuilds with the new type when the widget is updated', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TypeChip(type: PokemonType.fighting)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fighting'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TypeChip(type: PokemonType.water)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Fighting'), findsNothing);
    });
  });
}
