import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/pages/favorites/favorites_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/pages/settings/settings_page.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/teams_list_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repositories/mock_pokemon_repository.dart';

void main() {
  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies(Environment.dev);
    // O11: the repository is injected directly instead of relying on a
    // flavor-provided mock, so the graph never reaches the network.
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(MockPokemonRepository());
  });

  /// Lets the mocked image requests complete, then drives frames until the
  /// tree is quiet.
  ///
  /// `pumpAndSettle` cannot be used on the detail screen: it keeps an
  /// indeterminate `CircularProgressIndicator` mounted, so a frame is always
  /// scheduled and `pumpAndSettle` never returns. This pumps a bounded
  /// number of frames instead.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    for (var i = 0; i < 40; i++) {
      if (!tester.binding.hasScheduledFrame) break;
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Widget createRouterApp(
    String initialLocation, {
    Locale locale = const Locale('en'),
  }) {
    final router = createAppRouter(initialLocation: initialLocation);
    return MultiBlocProvider(
      providers: [
        if (getIt.isRegistered<LanguageCubit>())
          BlocProvider.value(value: getIt<LanguageCubit>()),
        if (getIt.isRegistered<PreferencesCubit>())
          BlocProvider.value(value: getIt<PreferencesCubit>()),
        if (getIt.isRegistered<FavoritesCubit>())
          BlocProvider.value(value: getIt<FavoritesCubit>()),
        if (getIt.isRegistered<RecentHistoryCubit>())
          BlocProvider.value(value: getIt<RecentHistoryCubit>()),
        if (getIt.isRegistered<ComparisonCubit>())
          BlocProvider.value(value: getIt<ComparisonCubit>()),
        if (getIt.isRegistered<TeamsCubit>())
          BlocProvider.value(value: getIt<TeamsCubit>()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
      ),
    );
  }

  group('AppRouter canonical routes', () {
    testWidgets('navigating to / loads HomePage', (tester) async {
      await tester.pumpWidget(createRouterApp(AppRoutes.home));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('navigating to /pokemon/pikachu resolves to Detail with name', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp(AppRoutes.pokemon('pikachu')));
        await settle(tester);

        expect(find.byType(PokemonDetailPage), findsOneWidget);
        final detailWidget = tester.widget<PokemonDetailPage>(
          find.byType(PokemonDetailPage),
        );
        expect(detailWidget.pokemonName, equals('pikachu'));
      });
    });

    testWidgets(
      'navigating to /pokemon/25 resolves to Detail with numeric ID',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createRouterApp(AppRoutes.pokemon('25')));
          await settle(tester);

          expect(find.byType(PokemonDetailPage), findsOneWidget);
          final detailWidget = tester.widget<PokemonDetailPage>(
            find.byType(PokemonDetailPage),
          );
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
        expect(find.byType(PokemonDetailPage), findsNothing);
      },
    );

    testWidgets(
      'navigating to negative or zero ID /pokemon/0 renders RouteErrorPage',
      (tester) async {
        await tester.pumpWidget(createRouterApp('/pokemon/0'));
        await tester.pumpAndSettle();

        expect(find.byType(RouteErrorPage), findsOneWidget);
        expect(find.byType(PokemonDetailPage), findsNothing);
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
      'returning from detail to home preserves search text and drops focus',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createRouterApp(AppRoutes.home));
          await tester.pumpAndSettle();

          // Type search query and maintain focus
          final textFieldFinder = find.byType(TextField);
          await tester.enterText(textFieldFinder, 'pikachu');
          await tester.pumpAndSettle();

          // Submit search
          await tester.tap(find.text('Search'), warnIfMissed: false);
          await settle(tester);

          expect(find.byType(PokemonDetailPage), findsOneWidget);

          // Pop back to home via AppBar back button
          await tester.tap(find.byType(BackButton), warnIfMissed: false);
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          final textField = tester.widget<TextField>(find.byType(TextField));
          expect(textField.controller?.text, equals('pikachu'));
          // O8: the home page unfocuses before pushing the detail route, so
          // coming back must not raise the soft keyboard again.
          expect(textField.focusNode?.hasFocus, isFalse);
        });
      },
    );

    testWidgets('navigating to /favorites loads FavoritesPage', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp(AppRoutes.favorites));
        await settle(tester);

        expect(find.byType(FavoritesPage), findsOneWidget);
      });
    });

    testWidgets('navigating to /pokedex loads PokedexBrowsePage', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp(AppRoutes.pokedex));
        await settle(tester);

        expect(find.byType(PokedexBrowsePage), findsOneWidget);
      });
    });

    testWidgets('navigating to /compare loads ComparisonPage', (tester) async {
      await mockNetworkImagesFor(() async {
        getIt<ComparisonCubit>().clear();
        await tester.pumpWidget(createRouterApp(AppRoutes.compare));
        await settle(tester);

        expect(find.byType(ComparisonPage), findsOneWidget);
      });
    });

    testWidgets('navigating to /settings loads SettingsPage', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp(AppRoutes.settings));
        await settle(tester);

        expect(find.byType(SettingsPage), findsOneWidget);
      });
    });

    testWidgets('navigating to /teams loads TeamsListPage', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createRouterApp(AppRoutes.teams));
        await settle(tester);

        expect(find.byType(TeamsListPage), findsOneWidget);
      });
    });

    testWidgets('navigating to /teams/:teamId loads TeamDetailPage', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = getIt<TeamsCubit>().createTeam('Router Team');
        await tester.pumpWidget(createRouterApp(AppRoutes.team(teamId)));
        await settle(tester);

        expect(find.byType(TeamDetailPage), findsOneWidget);
        expect(find.text('Router Team'), findsOneWidget);
      });
    });
  });
}
