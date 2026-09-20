import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies('mock');
  });

  Future<void> pumpDetailApp(
    WidgetTester tester, {
    String pokemon = 'bulbasaur',
  }) async {
    await mockNetworkImagesFor(() async {
      final router = createAppRouter(initialLocation: '/pokemon/$pokemon');
      await tester.pumpWidget(MyApp(router: router));
      await tester.pumpAndSettle();
    });
  }

  group('Detail Page - Favorites, Recents & Preferences', () {
    setUp(() {
      if (getIt.isRegistered<FavoritesCubit>()) {
        final favoritesCubit = getIt<FavoritesCubit>();
        for (final fav in favoritesCubit.state.favorites) {
          favoritesCubit.removeFavorite(fav.id);
        }
      }
      if (getIt.isRegistered<RecentHistoryCubit>()) {
        getIt<RecentHistoryCubit>().clearAllHistory();
      }
      if (getIt.isRegistered<PreferencesCubit>()) {
        getIt<PreferencesCubit>().setUnitSystem(UnitSystem.metric);
      }
    });

    testWidgets(
      'records pokemon in RecentHistoryCubit when detail page loads',
      (tester) async {
        await pumpDetailApp(tester, pokemon: 'bulbasaur');

        final recentHistoryCubit = getIt<RecentHistoryCubit>();
        expect(recentHistoryCubit.state.recentPokemon, isNotEmpty);
        expect(recentHistoryCubit.state.recentPokemon.first.id, 1);
        expect(recentHistoryCubit.state.recentPokemon.first.name, 'bulbasaur');
      },
    );

    testWidgets(
      'toggles favorite on DetailAppBar and synchronizes with FavoritesCubit',
      (tester) async {
        await pumpDetailApp(tester, pokemon: 'bulbasaur');

        final favoritesCubit = getIt<FavoritesCubit>();
        expect(favoritesCubit.isFavorite(1), isFalse);
        expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

        // Tap favorite button to add to favorites
        await tester.tap(find.byIcon(Icons.favorite_border_rounded));
        await tester.pumpAndSettle();

        expect(favoritesCubit.isFavorite(1), isTrue);
        expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

        // Tap favorite button to remove from favorites
        await tester.tap(find.byIcon(Icons.favorite_rounded));
        await tester.pumpAndSettle();

        expect(favoritesCubit.isFavorite(1), isFalse);
        expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'formats height and weight according to PreferencesCubit unit system',
      (tester) async {
        final preferencesCubit = getIt<PreferencesCubit>();
        preferencesCubit.setUnitSystem(UnitSystem.metric);

        await pumpDetailApp(tester, pokemon: 'bulbasaur');

        // In Metric: Bulbasaur is 0.7 m and 6.9 kg
        expect(find.text('0.7 m'), findsOneWidget);
        expect(find.text('6.9 kg'), findsOneWidget);

        // Switch to Imperial
        preferencesCubit.setUnitSystem(UnitSystem.imperial);
        await tester.pumpAndSettle();

        // In Imperial: Bulbasaur is 2' 04" and 15.2 lbs
        expect(find.text('2\' 04"'), findsOneWidget);
        expect(find.text('15.2 lbs'), findsOneWidget);
      },
    );
  });
}
