import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card_skeleton.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokedexBloc extends Mock implements PokedexBloc {}

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockPokedexBloc bloc;
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

  setUp(() {
    bloc = _MockPokedexBloc();
    comparisonCubit = ComparisonCubit(_MockEnLogger());
    streamController = StreamController<PokedexState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  Widget buildTestableWidget(Size screenSize) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PokedexBloc>.value(value: bloc),
            BlocProvider<ComparisonCubit>.value(value: comparisonCubit),
          ],
          child: const PokedexBrowsePage(),
        ),
      ),
    );
  }

  group('PokedexBrowsePage', () {
    testWidgets('renders skeletons when loading initial index', (tester) async {
      when(() => bloc.state).thenReturn(
        PokedexState.initial().copyWith(status: PokedexStatus.loading),
      );

      await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
      await tester.pump();

      expect(find.byType(PokemonCardSkeleton), findsWidgets);
    });

    testWidgets('renders pokemon cards on successful index load', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => bloc.state).thenReturn(
          PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            visibleEntries: sampleEntries,
          ),
        );

        await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
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
          PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: const [],
            visibleEntries: const [],
            searchQuery: 'xyznonexistent',
          ),
        );

        await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
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

    testWidgets('renders error view with retry button on failure', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        PokedexState.initial().copyWith(
          status: PokedexStatus.failure,
          failure: const NetworkUnavailableFailure('No internet'),
        ),
      );

      await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
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
          PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            visibleEntries: sampleEntries,
          ),
        );

        // Phone size (390 x 844)
        await tester.pumpWidget(buildTestableWidget(const Size(390, 844)));
        await tester.pump();
        expect(find.byType(PokemonCard), findsNWidgets(3));

        // Tablet size (1024 x 768)
        await tester.pumpWidget(buildTestableWidget(const Size(1024, 768)));
        await tester.pump();
        expect(find.byType(PokemonCard), findsNWidgets(3));
      });
    });

    testWidgets(
      'syncs search field text via BlocListener when state search query changes',
      (tester) async {
        final state = PokedexState.initial().copyWith(
          status: PokedexStatus.success,
          allEntries: sampleEntries,
          filteredEntries: sampleEntries,
          visibleEntries: sampleEntries,
          searchQuery: '',
        );
        when(() => bloc.state).thenReturn(state);

        await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
        await tester.pump();

        final updatedState = state.copyWith(searchQuery: 'pikachu');
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
          final refreshingState = PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            visibleEntries: sampleEntries,
            isRefreshing: true,
          );
          when(() => bloc.state).thenReturn(refreshingState);

          await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
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
            PokedexState.initial().copyWith(
              status: PokedexStatus.success,
              allEntries: interleavedEntries,
              filteredEntries: interleavedEntries,
              visibleEntries: interleavedEntries,
              formFilter: PokedexFormFilter.all,
            ),
          );

          await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
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
          PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            visibleEntries: sampleEntries,
          ),
        );

        comparisonCubit.addEntry(sampleEntries[0]);
        comparisonCubit.addEntry(sampleEntries[1]);

        await tester.pumpWidget(buildTestableWidget(const Size(400, 800)));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(find.byTooltip('Compare'), findsOneWidget);
      });
    });

    testWidgets('tapping compare action navigates to /compare', (tester) async {
      await mockNetworkImagesFor(() async {
        await configureDependencies('mock');
        when(() => bloc.state).thenReturn(
          PokedexState.initial().copyWith(
            status: PokedexStatus.success,
            allEntries: sampleEntries,
            filteredEntries: sampleEntries,
            visibleEntries: sampleEntries,
          ),
        );

        final router = GoRouter(
          initialLocation: '/pokedex',
          routes: [
            GoRoute(
              path: '/pokedex',
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<PokedexBloc>.value(value: bloc),
                  BlocProvider<ComparisonCubit>.value(value: comparisonCubit),
                ],
                child: const PokedexBrowsePage(),
              ),
            ),
            GoRoute(
              path: '/compare',
              builder: (context, state) => BlocProvider<ComparisonCubit>.value(
                value: comparisonCubit,
                child: const ComparisonPage(),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        );
        await tester.pump();

        await tester.tap(find.byTooltip('Compare'));
        await tester.pumpAndSettle();

        expect(find.byType(ComparisonPage), findsOneWidget);
      });
    });
  });
}
