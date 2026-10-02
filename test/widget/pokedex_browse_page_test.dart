import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card_skeleton.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

class _MockPokedexBloc extends Mock implements PokedexBloc {}

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockPokedexBloc bloc;
  late TestAppCubits cubits;
  late ComparisonCubit comparisonCubit;
  late StreamController<PokedexState> streamController;

  final sampleEntries = [
    const PokemonIndexEntry(
      id: 1,
      name: 'bulbasaur',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
      types: [PokemonType.grass, PokemonType.poison],
    ),
    const PokemonIndexEntry(
      id: 4,
      name: 'charmander',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
      types: [PokemonType.fire],
    ),
    const PokemonIndexEntry(
      id: 7,
      name: 'squirtle',
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
      types: [PokemonType.water],
    ),
  ];

  setUpAll(() {
    // ComparisonCubit loads the details of every entry it holds.
    registerFallbackValue(PokemonName('bulbasaur'));
    // PokemonCard reads FavoritesCubit, which is hydrated.
    ensureHydratedStorage();
  });

  setUp(() {
    bloc = _MockPokedexBloc();
    final repository = _MockPokemonRepository();
    when(
      () => repository.getPokemon(any()),
    ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));
    HydratedBloc.storage = InMemoryHydratedStorage();
    cubits = TestAppCubits(
      comparison: ComparisonCubit(_MockEnLogger(), repository),
    );
    comparisonCubit = cubits.comparison;
    streamController = StreamController<PokedexState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
    await cubits.close();
  });

  /// Pumps the browse page on a screen of [screenSize].
  Future<void> pumpPage(WidgetTester tester, Size screenSize) {
    return tester.pumpApp(
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: BlocProvider<PokedexBloc>.value(
          value: bloc,
          child: const PokedexBrowsePage(),
        ),
      ),
      cubits: cubits,
    );
  }

  group('PokedexBrowsePage', () {
    testWidgets('renders skeletons when loading initial index', (tester) async {
      when(() => bloc.state).thenReturn(
        const PokedexState().copyWith(status: PokedexStatus.loading),
      );

      await pumpPage(tester, const Size(400, 800));
      await tester.pump();

      expect(find.byType(PokemonCardSkeleton), findsWidgets);
    });

    testWidgets('renders pokemon cards on successful index load', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
          ),
        );

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();

        expect(find.byType(PokemonCard), findsNWidgets(3));
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);
        expect(find.text('Squirtle'), findsOneWidget);
      });
    });

    testWidgets('renders empty search state with clear filters button', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filters: PokedexFilters(query: 'xyznonexistent'),
          ),
        );

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();

        expect(
          find.text('No Pokémon found matching your filters'),
          findsOneWidget,
        );
        expect(find.text('Clear Filters'), findsOneWidget);

        // Tap clear filters
        await tester.tap(find.text('Clear Filters'));
        await tester.pump();

        verify(() => bloc.add(const PokedexClearFiltersEvent())).called(1);
      });
    });

    testWidgets(
      'shows the type loading indicator instead of the empty state while the '
      'ids of a selected type are loading',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filters: PokedexFilters(selectedTypes: {PokemonType.fire}),
            loadingTypes: {PokemonType.fire},
          ),
        );

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(
          find.text('No Pokémon found matching your filters'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a type filter failure is surfaced as a snack bar and no longer hides the '
      'empty results view',
      (tester) async {
        final initialState = const PokedexState().copyWith(
          status: PokedexStatus.success,
          allEntries: sampleEntries,
          filters: PokedexFilters(selectedTypes: {PokemonType.fire}),
          loadingTypes: {PokemonType.fire},
        );
        when(() => bloc.state).thenReturn(initialState);

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();
        expect(find.byType(SnackBar), findsNothing);

        // The ids never arrive: the type is dropped and the failure is reported.
        final failedState = initialState.copyWith(
          filters: const PokedexFilters(),
          loadingTypes: const {},
          typeFilterFailure: const NetworkUnavailableFailure('No internet'),
        );
        when(() => bloc.state).thenReturn(failedState);
        streamController.add(failedState);
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('No internet connection. Please check your network.'),
          findsOneWidget,
        );
        expect(
          find.text('No Pokémon found matching your filters'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const PokedexState().copyWith(
          status: PokedexStatus.failure,
          failure: const NetworkUnavailableFailure('No internet'),
        ),
      );

      await pumpPage(tester, const Size(400, 800));
      await tester.pump();

      expect(
        find.text('No internet connection. Please check your network.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => bloc.add(const PokedexFetchIndexEvent())).called(1);
    });

    testWidgets('renders responsive layouts on phone vs tablet', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
          ),
        );

        // Phone size (390 x 844)
        await pumpPage(tester, const Size(390, 844));
        await tester.pump();
        expect(find.byType(PokemonCard), findsNWidgets(3));

        // Tablet size (1024 x 768)
        await pumpPage(tester, const Size(1024, 768));
        await tester.pump();
        expect(find.byType(PokemonCard), findsNWidgets(3));
      });
    });

    testWidgets(
      'syncs search field text via BlocListener when state search query changes',
      (tester) async {
        final state = const PokedexState().copyWith(
          status: PokedexStatus.success,
          allEntries: sampleEntries,
          filteredEntries: sampleEntries,
        );
        when(() => bloc.state).thenReturn(state);

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();

        final updatedState = state.copyWith(
          filters: const PokedexFilters(query: 'pikachu'),
        );
        when(() => bloc.state).thenReturn(updatedState);
        streamController.add(updatedState);
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'pikachu');
      },
    );

    testWidgets(
      'pull to refresh does not throw when widget unmounts during refresh',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final refreshingState = const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            isRefreshing: true,
          );
          when(() => bloc.state).thenReturn(refreshingState);

          await pumpPage(tester, const Size(400, 800));
          await tester.pump();

          // Trigger pull to refresh gesture
          await tester.fling(
            find.byType(CustomScrollView),
            const Offset(0, 300),
            1000,
          );
          await tester.pump();

          // Unmount the widget while refresh is in-flight and close stream
          await tester.pumpWidget(const MaterialApp(home: SizedBox()));
          await streamController.close();
          await tester.pump();

          // Re-create streamController for tearDown
          streamController = StreamController<PokedexState>.broadcast();
          when(() => bloc.stream).thenAnswer((_) => streamController.stream);
        });
      },
    );

    testWidgets(
      'renders interleaved ordering for forms (Venusaur -> Mega Venusaur -> Charmander)',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final interleavedEntries = [
            const PokemonIndexEntry(
              id: 3,
              name: 'venusaur',
              detailUrl: 'https://pokeapi.co/api/v2/pokemon/3/',
              types: [PokemonType.grass, PokemonType.poison],
            ),
            const PokemonIndexEntry(
              id: 10033,
              name: 'venusaur-mega',
              detailUrl: 'https://pokeapi.co/api/v2/pokemon/10033/',
              parentSpeciesId: 3,
              parentSpeciesName: 'venusaur',
              formCategory: PokemonFormCategory.mega,
              types: [PokemonType.grass, PokemonType.poison],
            ),
            const PokemonIndexEntry(
              id: 4,
              name: 'charmander',
              detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
              types: [PokemonType.fire],
            ),
          ];

          when(() => bloc.state).thenReturn(
            const PokedexState().copyWith(
              status: PokedexStatus.success,
              allEntries: interleavedEntries,
              filteredEntries: interleavedEntries,
              filters: PokedexFilters(formFilter: PokedexFormFilter.all),
            ),
          );

          await pumpPage(tester, const Size(400, 800));
          await tester.pump();

          final cardTitles = find
              .descendant(
                of: find.byType(PokemonCard),
                matching: find.byType(Text),
              )
              .evaluate()
              .map((element) => (element.widget as Text).data)
              .whereType<String>()
              .toList();

          expect(cardTitles.contains('Venusaur'), isTrue);
          expect(cardTitles.contains('Mega Venusaur'), isTrue);
          expect(cardTitles.contains('Charmander'), isTrue);

          final venusaurIndex = cardTitles.indexOf('Venusaur');
          final megaVenusaurIndex = cardTitles.indexOf('Mega Venusaur');
          final charmanderIndex = cardTitles.indexOf('Charmander');

          expect(venusaurIndex, lessThan(megaVenusaurIndex));
          expect(megaVenusaurIndex, lessThan(charmanderIndex));
        });
      },
    );

    testWidgets('shows comparison badge count when entries are selected', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
          ),
        );

        comparisonCubit.addEntry(sampleEntries[0].summary);
        comparisonCubit.addEntry(sampleEntries[1].summary);

        await pumpPage(tester, const Size(400, 800));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.byTooltip('Compare'), findsOneWidget);
      });
    });

    testWidgets('tapping compare action navigates to /compare', (tester) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
          ),
        );

        final router = GoRouter(
          initialLocation: AppRoutes.pokedex,
          routes: [
            GoRoute(
              path: AppRoutes.pokedex,
              builder: (context, state) => BlocProvider<PokedexBloc>.value(
                value: bloc,
                child: const PokedexBrowsePage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.compare,
              builder: (context, state) => const ComparisonPage(),
            ),
          ],
        );

        await tester.pumpApp(router: router, cubits: cubits);
        await tester.pump();

        await tester.tap(find.byTooltip('Compare'));
        await tester.pumpAndSettle();

        expect(find.byType(ComparisonPage), findsOneWidget);
      });
    });
  });
}
