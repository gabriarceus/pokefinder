import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/src/1_presentation/pages/favorites/favorites_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

void main() {
  late TestAppCubits cubits;

  setUp(() {
    HydratedBloc.storage = InMemoryHydratedStorage();
    cubits = TestAppCubits();
  });

  tearDown(() => cubits.close());

  /// Lets the mocked image requests complete, then settles the animations.
  ///
  /// `pumpAndSettle` alone never returns while a `CircularProgressIndicator`
  /// is on screen waiting for an image, so the real async has to run first.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Pumps the favorites page, or [router] when given.
  Future<void> pumpFavorites(WidgetTester tester, {GoRouter? router}) {
    return tester.pumpApp(
      home: router == null ? const FavoritesPage() : null,
      router: router,
      cubits: cubits,
    );
  }

  group('FavoritesPage', () {
    testWidgets('renders empty state when there are no favorites', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await pumpFavorites(tester);
        await settle(tester);

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
          initialLocation: AppRoutes.favorites,
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (_, _) => const FavoritesPage(),
            ),
            GoRoute(
              path: AppRoutes.pokedex,
              builder: (_, _) {
                navigatedToPokedex = true;
                return const Scaffold(body: Text('Pokédex Browse'));
              },
            ),
          ],
        );

        await pumpFavorites(tester, router: router);
        await settle(tester);

        await tester.tap(find.text('Browse Pokédex'));
        await settle(tester);

        expect(navigatedToPokedex, isTrue);
      });
    });

    testWidgets('renders grid with favorite cards when favorites exist', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        cubits.favorites.addFavorite(
          const PokemonSummary(
            id: 25,
            name: 'pikachu',
            spriteUrl: 'https://pokeapi.co/sprite/25.png',
            types: [PokemonType.electric],
          ),
        );
        cubits.favorites.addFavorite(
          const PokemonSummary(
            id: 1,
            name: 'bulbasaur',
            spriteUrl: 'https://pokeapi.co/sprite/1.png',
            types: [PokemonType.grass, PokemonType.poison],
          ),
        );

        await pumpFavorites(tester);
        await settle(tester);

        expect(find.byType(PokemonCard), findsNWidgets(2));
        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
      });
    });

    testWidgets('changes sort order via sort popup menu', (tester) async {
      await mockNetworkImagesFor(() async {
        cubits.favorites.addFavorite(
          const PokemonSummary(
            id: 25,
            name: 'pikachu',
            spriteUrl: '',
            types: [PokemonType.electric],
          ),
        );
        cubits.favorites.addFavorite(
          const PokemonSummary(
            id: 1,
            name: 'bulbasaur',
            spriteUrl: '',
            types: [PokemonType.grass],
          ),
        );

        await pumpFavorites(tester);
        await settle(tester);

        // Open sort menu
        await tester.tap(find.byIcon(Icons.sort_rounded));
        await settle(tester);

        expect(find.text('Name: A - Z'), findsOneWidget);
        expect(find.text('Name: Z - A'), findsOneWidget);
        expect(find.text('Number: Lowest first'), findsOneWidget);
        expect(find.text('Number: Highest first'), findsOneWidget);
        expect(find.text('Recently Added'), findsOneWidget);

        // Tap Name: A - Z
        await tester.tap(find.text('Name: A - Z'));
        await settle(tester);

        expect(
          cubits.favorites.state.sortOrder,
          FavoriteSortOrder.nameAscending,
        );
      });
    });

    testWidgets(
      'removing a favorite updates the grid and transitions to empty state',
      (tester) async {
        await mockNetworkImagesFor(() async {
          cubits.favorites.addFavorite(
            const PokemonSummary(
              id: 25,
              name: 'pikachu',
              spriteUrl: '',
              types: [PokemonType.electric],
            ),
          );

          await pumpFavorites(tester);
          await settle(tester);

          expect(find.byType(PokemonCard), findsOneWidget);

          // Tap favorite icon on the card to unfavorite
          await tester.tap(find.byIcon(Icons.favorite));
          await settle(tester);

          expect(find.byType(PokemonCard), findsNothing);
          expect(find.text('No Favorites Yet'), findsOneWidget);
        });
      },
    );
  });
}
