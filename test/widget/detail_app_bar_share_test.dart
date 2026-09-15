import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/_app_bar.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_share_link.dart';

void main() {
  group('DetailAppBar share action', () {
    Widget buildAppBar({required Locale locale, VoidCallback? onShare}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(
          appBar: DetailAppBar(backgroundColor: Colors.green, onShare: onShare),
        ),
      );
    }

    testWidgets('renders the share button with tooltip and invokes it', (
      tester,
    ) async {
      var shared = 0;
      await tester.pumpWidget(
        buildAppBar(locale: const Locale('en'), onShare: () => shared++),
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
      await tester.pumpWidget(
        buildAppBar(locale: const Locale('it'), onShare: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Copia link'), findsOneWidget);
    });

    testWidgets('hides the share button when no handler is provided', (
      tester,
    ) async {
      await tester.pumpWidget(buildAppBar(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link_rounded), findsNothing);
    });
  });

  group('incoming share-link navigation', () {
    setUpAll(() async {
      ensureHydratedStorage();
      await configureDependencies('mock');
    });

    Widget createRouterApp(String initialLocation) {
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
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets(
      'cold-start from a shared deep link resolves to the same Pokémon',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final link = buildPokemonCanonicalPath('pikachu');
          expect(link, '/pokemon/pikachu');

          await tester.pumpWidget(createRouterApp(link!));
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);
          expect(
            tester.widget<Detail>(find.byType(Detail)).pokemonName,
            'pikachu',
          );

          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
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

        await tester.pumpWidget(
          createRouterApp(buildPokemonCanonicalPath(identifier)!),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Detail), findsOneWidget);
        expect(tester.widget<Detail>(find.byType(Detail)).pokemonName, '25');
      });
    });

    testWidgets('an invalid shared link hits the router error screen', (
      tester,
    ) async {
      await tester.pumpWidget(createRouterApp('/pokemon/invalid!param'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsOneWidget);
      expect(find.byType(Detail), findsNothing);
    });
  });

  group('Detail share copy end-to-end', () {
    setUpAll(() async {
      ensureHydratedStorage();
      await configureDependencies('mock');
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
          await tester.pumpAndSettle();
        });

        expect(find.byType(Detail), findsOneWidget);
        final shareButton = find.byTooltip('Copy link');
        expect(shareButton, findsOneWidget);

        await tester.tap(shareButton);
        await tester.pumpAndSettle();

        expect(copiedText, '/pokemon/bulbasaur');
        expect(find.text('Link copied to clipboard'), findsOneWidget);
      },
    );
  });
}
