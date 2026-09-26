import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockCryAudioController extends Mock implements CryAudioController {}

/// Pumps frames until [finder] matches.
///
/// `mockNetworkImagesFor` never completes the image request, so the detail
/// header's loading spinner animates forever and `pumpAndSettle` never returns.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Pumps a bounded number of frames so animations reach their final state.
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
    String pokemon = 'bulbasaur',
  }) async {
    await mockNetworkImagesFor(() async {
      final router = createAppRouter(initialLocation: '/pokemon/$pokemon');
      await tester.pumpWidget(MyApp(router: router));
      await pumpUntilFound(tester, find.byType(DetailHeader));
      await pumpFrames(tester);
    });
  }

  group('Detail Page - Favorites, Recents & Preferences', () {
    setUp(() {
      if (getIt.isRegistered<FavoritesCubit>()) {
        final favoritesCubit = getIt<FavoritesCubit>();
        for (final fav in favoritesCubit.state.favorites) {
          favoritesCubit.removeFavorite(fav.pokemon.id);
        }
      }
      if (getIt.isRegistered<RecentHistoryCubit>()) {
        getIt<RecentHistoryCubit>().clearAllHistory();
      }
      if (getIt.isRegistered<PreferencesCubit>()) {
        getIt<PreferencesCubit>()
          ..setUnitSystem(UnitSystem.metric)
          ..setAutoPlayCry(false);
      }
    });

    testWidgets(
      'records pokemon in RecentHistoryCubit when detail page loads',
      (tester) async {
        await pumpDetailApp(tester, pokemon: 'bulbasaur');

        final recentHistoryCubit = getIt<RecentHistoryCubit>();
        expect(recentHistoryCubit.state.recentPokemon, isNotEmpty);
        expect(recentHistoryCubit.state.recentPokemon.first.pokemon.id, 1);
        expect(
          recentHistoryCubit.state.recentPokemon.first.pokemon.name,
          'bulbasaur',
        );
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
        await pumpFrames(tester);

        expect(favoritesCubit.isFavorite(1), isTrue);
        expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

        // Tap favorite button to remove from favorites
        await tester.tap(find.byIcon(Icons.favorite_rounded));
        await pumpFrames(tester);

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
        await pumpFrames(tester);

        // In Imperial: Bulbasaur is 2' 04" and 15.2 lbs
        expect(find.text('2\' 04"'), findsOneWidget);
        expect(find.text('15.2 lbs'), findsOneWidget);
      },
    );
  });

  group('Detail Page - auto-play cry runs once per loaded Pokémon', () {
    late _MockCryAudioController audioController;

    setUp(() {
      audioController = _MockCryAudioController();
      when(() => audioController.state).thenReturn(const CryPlaybackState());
      when(
        () => audioController.stateStream,
      ).thenAnswer((_) => const Stream<CryPlaybackState>.empty());
      when(() => audioController.setVolume(any())).thenAnswer((_) async {});
      when(() => audioController.play(any())).thenAnswer((_) async {});
      when(() => audioController.toggle(any())).thenAnswer((_) async {});
      when(() => audioController.dispose()).thenAnswer((_) async {});

      getIt.unregister<CryAudioController>();
      getIt.registerFactory<CryAudioController>(() => audioController);

      getIt<RecentHistoryCubit>().clearAllHistory();
      getIt<PreferencesCubit>()
        ..setAutoPlayCry(true)
        ..setCryVolume(0.5);
    });

    testWidgets(
      'plays the cry exactly once although the bloc emits success repeatedly',
      (tester) async {
        await pumpDetailApp(tester, pokemon: 'bulbasaur');

        // The bloc emits PokemonBlocSuccess for the data, then again for the
        // background encounters: both carry the same Pokémon id, so the
        // listenWhen must collapse them into a single cry playback.
        verify(() => audioController.play(any())).called(1);
        verify(() => audioController.setVolume(0.5)).called(1);

        // ...and the history entry is recorded once, not twice.
        final recentPokemon = getIt<RecentHistoryCubit>().state.recentPokemon;
        expect(recentPokemon, hasLength(1));
        expect(recentPokemon.first.pokemon.id, 1);
      },
    );
  });
}
