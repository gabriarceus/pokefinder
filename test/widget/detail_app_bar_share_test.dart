import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/_app_bar.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_share_link.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

/// Pumps frames until [finder] matches.
///
/// `mockNetworkImagesFor` never completes the image request, so the detail
/// header's loading spinner animates forever and `pumpAndSettle` never returns.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Pumps a bounded number of frames, so pending animations (snack bars,
/// route transitions) reach their final state without waiting on the spinner.
Future<void> pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  group('DetailAppBar share action', () {
    Future<void> pumpAppBar(
      WidgetTester tester, {
      required Locale locale,
      VoidCallback? onShare,
    }) {
      // DetailAppBar is a sliver app bar: it must live in a scroll view.
      return tester.pumpApp(
        locale: locale,
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              DetailAppBar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                expandedHeight: kToolbarHeight + 120,
                background: const SizedBox.shrink(),
                onShare: onShare,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ],
          ),
        ),
      );
    }

    testWidgets('renders the share button with tooltip and invokes it', (
      tester,
    ) async {
      var shared = 0;
      await pumpAppBar(
        tester,
        locale: const Locale('en'),
        onShare: () => shared++,
      );
      await tester.pumpAndSettle();

      final shareButton = find.byTooltip('Copy link');
      expect(shareButton, findsOneWidget);
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);

      await tester.tap(shareButton);
      await tester.pumpAndSettle();
      expect(shared, 1);
    });

    testWidgets('localizes the share tooltip in Italian', (tester) async {
      await pumpAppBar(tester, locale: const Locale('it'), onShare: () {});
      await tester.pumpAndSettle();

      expect(find.byTooltip('Copia link'), findsOneWidget);
    });

    testWidgets('hides the share button when no handler is provided', (
      tester,
    ) async {
      await pumpAppBar(tester, locale: const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link_rounded), findsNothing);
    });
  });

  group('incoming share-link navigation', () {
    setUpAll(() async {
      ensureHydratedStorage();
      await configureDependencies(Environment.dev);
    });

    Future<void> pumpRouterApp(WidgetTester tester, String initialLocation) {
      return tester.pumpApp(
        router: createAppRouter(initialLocation: initialLocation),
        cubits: TestAppCubits(
          preferences: getIt<PreferencesCubit>(),
          language: getIt<LanguageCubit>(),
          favorites: getIt<FavoritesCubit>(),
          recentHistory: getIt<RecentHistoryCubit>(),
          comparison: getIt<ComparisonCubit>(),
          teams: getIt<TeamsCubit>(),
        ),
      );
    }

    testWidgets(
      'cold-start from a shared deep link resolves to the same Pokémon',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final link = buildPokemonCanonicalPath('pikachu');
          expect(link, '/pokemon/pikachu');

          await pumpRouterApp(tester, link!);
          // The header only exists once the Pokémon has loaded, so waiting
          // for it also lets the mock repository's fetch timer elapse.
          await pumpUntilFound(tester, find.byType(DetailHeader));

          expect(find.byType(PokemonDetailPage), findsOneWidget);
          expect(
            tester
                .widget<PokemonDetailPage>(find.byType(PokemonDetailPage))
                .pokemonName,
            'pikachu',
          );

          await tester.tap(find.byType(BackButton));
          await pumpUntilFound(tester, find.byType(HomePage));
          expect(find.byType(HomePage), findsOneWidget);
        });
      },
    );

    testWidgets('cold-start from a shared numeric-ID link resolves to Detail', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final uri = buildPokemonShareUri('25');
        final identifier = parsePokemonShareLink(uri.toString());
        expect(identifier, '25');

        await pumpRouterApp(tester, buildPokemonCanonicalPath(identifier)!);
        await pumpUntilFound(tester, find.byType(DetailHeader));

        expect(find.byType(PokemonDetailPage), findsOneWidget);
        expect(
          tester
              .widget<PokemonDetailPage>(find.byType(PokemonDetailPage))
              .pokemonName,
          '25',
        );
      });
    });

    testWidgets('an invalid shared link hits the router error screen', (
      tester,
    ) async {
      await pumpRouterApp(tester, '/pokemon/invalid!param');
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsOneWidget);
      expect(find.byType(PokemonDetailPage), findsNothing);
    });
  });

  group('Detail share copy end-to-end', () {
    setUpAll(() async {
      ensureHydratedStorage();
      await configureDependencies(Environment.dev);
    });

    testWidgets(
      'tapping share copies the canonical link and shows confirmation',
      (tester) async {
        String? copiedText;
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(SystemChannels.platform, (
          call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            copiedText =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        });
        addTearDown(
          () =>
              messenger.setMockMethodCallHandler(SystemChannels.platform, null),
        );

        await mockNetworkImagesFor(() async {
          final router = createAppRouter(initialLocation: '/pokemon/bulbasaur');
          await tester.pumpWidget(MyApp(router: router));
          await pumpUntilFound(tester, find.byType(DetailHeader));
        });

        expect(find.byType(PokemonDetailPage), findsOneWidget);
        final shareButton = find.byTooltip('Copy link');
        expect(shareButton, findsOneWidget);

        await tester.tap(shareButton);
        await pumpFrames(tester);

        expect(copiedText, '/pokemon/bulbasaur');
        expect(find.text('Link copied to clipboard'), findsOneWidget);
      },
    );
  });
}
