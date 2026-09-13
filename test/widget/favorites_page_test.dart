import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/favorites/favorites_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  setUpAll(() {
    ensureHydratedStorage();
  });

  Widget buildTestableWidget({
    required FavoritesCubit favoritesCubit,
    GoRouter? router,
  }) {
    if (router != null) {
      return BlocProvider<FavoritesCubit>.value(
        value: favoritesCubit,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
    }

    return BlocProvider<FavoritesCubit>.value(
      value: favoritesCubit,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: FavoritesPage(),
      ),
    );
  }

  group('FavoritesPage', () {
    late FavoritesCubit favoritesCubit;

    setUp(() {
      HydratedBloc.storage = InMemoryHydratedStorage();
      favoritesCubit = FavoritesCubit(_MockEnLogger());
    });

    tearDown(() {
      favoritesCubit.close();
    });

    testWidgets('renders empty state when there are no favorites', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          buildTestableWidget(favoritesCubit: favoritesCubit),
        );
        await tester.pumpAndSettle();

        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('No Favorites Yet'), findsOneWidget);
        expect(
          find.text(
            'Tap the heart icon on any Pokémon to add it to your favorites.',
          ),
          findsOneWidget,
        );
        expect(find.text('Browse Pokédex'), findsOneWidget);
        expect(find.byType(PokemonCard), findsNothing);
      });
    });

    testWidgets('tapping browse pokedex button navigates to /pokedex', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        var navigatedToPokedex = false;
        final router = GoRouter(
          initialLocation: '/favorites',
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (_, _) => const FavoritesPage(),
            ),
            GoRoute(
              path: '/pokedex',
              builder: (_, _) {
                navigatedToPokedex = true;
                return const Scaffold(body: Text('Pokédex Browse'));
              },
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(favoritesCubit: favoritesCubit, router: router),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Browse Pokédex'));
        await tester.pumpAndSettle();

        expect(navigatedToPokedex, isTrue);
      });
    });

    testWidgets('renders grid with favorite cards when favorites exist', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        favoritesCubit.addFavorite(
          id: 25,
          name: 'pikachu',
          spriteUrl: 'https://pokeapi.co/sprite/25.png',
          types: [PokemonType.electric],
        );
        favoritesCubit.addFavorite(
          id: 1,
          name: 'bulbasaur',
          spriteUrl: 'https://pokeapi.co/sprite/1.png',
          types: [PokemonType.grass, PokemonType.poison],
        );

        await tester.pumpWidget(
          buildTestableWidget(favoritesCubit: favoritesCubit),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PokemonCard), findsNWidgets(2));
        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
      });
    });

    testWidgets('changes sort order via sort popup menu', (tester) async {
      await mockNetworkImagesFor(() async {
        favoritesCubit.addFavorite(
          id: 25,
          name: 'pikachu',
          spriteUrl: '',
          types: [PokemonType.electric],
        );
        favoritesCubit.addFavorite(
          id: 1,
          name: 'bulbasaur',
          spriteUrl: '',
          types: [PokemonType.grass],
        );

        await tester.pumpWidget(
          buildTestableWidget(favoritesCubit: favoritesCubit),
        );
        await tester.pumpAndSettle();

        // Open sort menu
        await tester.tap(find.byIcon(Icons.sort_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Name: A - Z'), findsOneWidget);
        expect(find.text('Name: Z - A'), findsOneWidget);
        expect(find.text('Number: Lowest first'), findsOneWidget);
        expect(find.text('Number: Highest first'), findsOneWidget);
        expect(find.text('Recently Added'), findsOneWidget);

        // Tap Name: A - Z
        await tester.tap(find.text('Name: A - Z'));
        await tester.pumpAndSettle();

        expect(favoritesCubit.state.sortOrder, FavoriteSortOrder.nameAscending);
      });
    });

    testWidgets(
      'removing a favorite updates the grid and transitions to empty state',
      (tester) async {
        await mockNetworkImagesFor(() async {
          favoritesCubit.addFavorite(
            id: 25,
            name: 'pikachu',
            spriteUrl: '',
            types: [PokemonType.electric],
          );

          await tester.pumpWidget(
            buildTestableWidget(favoritesCubit: favoritesCubit),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PokemonCard), findsOneWidget);

          // Tap favorite icon on the card to unfavorite
          await tester.tap(find.byIcon(Icons.favorite));
          await tester.pumpAndSettle();

          expect(find.byType(PokemonCard), findsNothing);
          expect(find.text('No Favorites Yet'), findsOneWidget);
        });
      },
    );
  });
}
