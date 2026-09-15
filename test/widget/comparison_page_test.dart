import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockGetPokemonUseCase extends Mock implements GetPokemonUseCase {}

class _MockGetEncountersUseCase extends Mock
    implements GetPokemonEncountersUseCase {}

class _MockGetFormDetailsUseCase extends Mock
    implements GetPokemonFormDetailsUseCase {}

const _bulbasaurEntry = PokemonIndexEntry(
  id: 1,
  name: 'bulbasaur',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
  types: [PokemonType.grass, PokemonType.poison],
);
const _pikachuEntry = PokemonIndexEntry(
  id: 25,
  name: 'pikachu',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
  types: [PokemonType.electric],
);
const _charmanderEntry = PokemonIndexEntry(
  id: 4,
  name: 'charmander',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
  types: [PokemonType.fire],
);

void main() {
  Widget buildHarness({
    required ComparisonCubit comparisonCubit,
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<ComparisonCubit>.value(
        value: comparisonCubit,
        child: Scaffold(body: child),
      ),
    );
  }

  group('ComparisonPage empty state', () {
    testWidgets('explains how to add entries', (tester) async {
      final cubit = ComparisonCubit(_MockEnLogger());

      await tester.pumpWidget(
        buildHarness(comparisonCubit: cubit, child: const ComparisonPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Pokémon to compare'), findsOneWidget);
      expect(
        find.text(
          'Add up to 2 Pokémon from the Pokédex cards or the detail screen to compare them side by side.',
        ),
        findsOneWidget,
      );
      expect(find.text('Browse Pokédex'), findsOneWidget);
    });

    testWidgets('localizes the empty state in Italian', (tester) async {
      final cubit = ComparisonCubit(_MockEnLogger());

      await tester.pumpWidget(
        buildHarness(
          comparisonCubit: cubit,
          child: const ComparisonPage(),
          locale: const Locale('it'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nessun Pokémon da confrontare'), findsOneWidget);
      expect(find.text('Esplora Pokédex'), findsOneWidget);
    });
  });

  group('ComparisonPage add/remove/clear flows', () {
    setUpAll(() async {
      await configureDependencies('mock');
    });

    testWidgets('renders two entries with aligned stat rows', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger())
          ..addEntry(_bulbasaurEntry)
          ..addEntry(_pikachuEntry);

        await tester.pumpWidget(
          buildHarness(comparisonCubit: cubit, child: const ComparisonPage()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Compare'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        // Single shared stat section driven by buildComparisonStatRows.
        expect(find.text('Base Stats'), findsOneWidget);
        // Aligned rows show both sides side by side with leader semantics.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'HP: Bulbasaur 45, Pikachu 45',
          ),
          findsOneWidget,
        );
        // Totals render side by side in one shared row.
        expect(find.text('318'), findsNWidgets(2));
        expect(find.text('Total'), findsOneWidget);
        expect(find.byTooltip('Remove from comparison'), findsNWidgets(2));
        expect(find.byTooltip('Copy link'), findsNWidgets(2));
      });
    });

    testWidgets('stays side by side on phone portrait (390x844)', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final cubit = ComparisonCubit(_MockEnLogger())
          ..addEntry(_bulbasaurEntry)
          ..addEntry(_pikachuEntry);

        await tester.pumpWidget(
          buildHarness(comparisonCubit: cubit, child: const ComparisonPage()),
        );
        await tester.pumpAndSettle();

        // Both sides remain visible with a single shared stat table.
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Base Stats'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'HP: Bulbasaur 45, Pikachu 45',
          ),
          findsOneWidget,
        );
        expect(find.text('318'), findsNWidgets(2));
      });
    });

    testWidgets('renders placeholder icon when sprite URL is empty', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final encountersUseCase = _MockGetEncountersUseCase();
        final formDetailsUseCase = _MockGetFormDetailsUseCase();
        final logger = _MockEnLogger();
        final pokemonUseCase = _MockGetPokemonUseCase();
        registerFallbackValue(PokemonName('fallback'));
        when(
          () => pokemonUseCase(any(), cancelToken: any(named: 'cancelToken')),
        ).thenAnswer(
          (_) async => Right<PokemonFailure, Pokemon>(buildPokemon(sprite: '')),
        );
        when(
          () =>
              encountersUseCase(any(), cancelToken: any(named: 'cancelToken')),
        ).thenAnswer(
          (_) async => const Right<PokemonFailure, List<PokemonEncounter>>([]),
        );
        final bloc = PokemonBloc(
          pokemonUseCase,
          encountersUseCase,
          formDetailsUseCase,
          logger,
        )..add(FetchPokemonEvent('bulbasaur'));
        final cubit = ComparisonCubit(_MockEnLogger());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<ComparisonCubit>.value(
              value: cubit,
              child: Scaffold(
                body: BlocProvider<PokemonBloc>.value(
                  value: bloc,
                  child: const ComparisonSlotBody(entry: _bulbasaurEntry),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
      });
    });

    testWidgets('remove-one keeps the other side, clear-all empties', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger())
          ..addEntry(_bulbasaurEntry)
          ..addEntry(_pikachuEntry);

        await tester.pumpWidget(
          buildHarness(comparisonCubit: cubit, child: const ComparisonPage()),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Remove from comparison').first);
        await tester.pumpAndSettle();

        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsNothing);
        expect(find.text('Add a second Pokémon to compare'), findsOneWidget);

        await tester.tap(find.byTooltip('Clear comparison'));
        await tester.pumpAndSettle();

        expect(find.text('No Pokémon to compare'), findsOneWidget);
        expect(cubit.state.entries, isEmpty);
      });
    });
  });

  group('ComparisonSlotBody failure isolation', () {
    late _MockGetPokemonUseCase failingUseCase;
    late _MockGetPokemonUseCase successUseCase;
    late _MockGetEncountersUseCase encountersUseCase;
    late _MockGetFormDetailsUseCase formDetailsUseCase;
    late _MockEnLogger logger;

    setUp(() {
      registerFallbackValue(PokemonName('fallback'));
      failingUseCase = _MockGetPokemonUseCase();
      successUseCase = _MockGetPokemonUseCase();
      encountersUseCase = _MockGetEncountersUseCase();
      formDetailsUseCase = _MockGetFormDetailsUseCase();
      logger = _MockEnLogger();

      when(
        () => failingUseCase(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async =>
            const Left<PokemonFailure, Pokemon>(PokemonNotFoundFailure()),
      );
      when(
        () => successUseCase(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => Right<PokemonFailure, Pokemon>(
          buildPokemon(
            id: 4,
            name: 'charmander',
            type1: PokemonType.fire,
            type2: null,
          ),
        ),
      );
      when(
        () => encountersUseCase(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => const Right<PokemonFailure, List<PokemonEncounter>>([]),
      );
    });

    PokemonBloc buildBloc(GetPokemonUseCase useCase) =>
        PokemonBloc(useCase, encountersUseCase, formDetailsUseCase, logger);

    testWidgets('failed entry shows retry without destroying the valid side', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final failingBloc = buildBloc(failingUseCase)
          ..add(FetchPokemonEvent('missingno'));
        final successBloc = buildBloc(successUseCase)
          ..add(FetchPokemonEvent('charmander'));
        final cubit = ComparisonCubit(_MockEnLogger());

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<ComparisonCubit>.value(
              value: cubit,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BlocProvider<PokemonBloc>.value(
                          value: failingBloc,
                          child: const ComparisonSlotBody(
                            entry: PokemonIndexEntry(
                              id: 999,
                              name: 'missingno',
                              detailUrl: '',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: BlocProvider<PokemonBloc>.value(
                          value: successBloc,
                          child: const ComparisonSlotBody(
                            entry: _charmanderEntry,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pokémon not found.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);
        expect(find.text('Base Stats'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        verify(
          () => failingUseCase(any(), cancelToken: any(named: 'cancelToken')),
        ).called(2);
        expect(find.text('Pokémon not found.'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);
      });
    });
  });

  group('PokemonCard compare action', () {
    testWidgets('tapping compare adds the entry and confirms', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger());

        await tester.pumpWidget(
          buildHarness(
            comparisonCubit: cubit,
            child: const SizedBox(
              width: 160,
              height: 200,
              child: PokemonCard(entry: _bulbasaurEntry, onTap: doNothing),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.compare_arrows_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(cubit.isSelected(1), isTrue);
        expect(find.text('Added to comparison'), findsOneWidget);
      });
    });

    testWidgets('tapping compare again removes the entry', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger())
          ..addEntry(_bulbasaurEntry);

        await tester.pumpWidget(
          buildHarness(
            comparisonCubit: cubit,
            child: const SizedBox(
              width: 160,
              height: 200,
              child: PokemonCard(entry: _bulbasaurEntry, onTap: doNothing),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.compare_arrows_rounded));
        await tester.pumpAndSettle();

        expect(cubit.isSelected(1), isFalse);
      });
    });

    testWidgets('third entry is refused with a full message', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger())
          ..addEntry(_bulbasaurEntry)
          ..addEntry(_pikachuEntry);

        await tester.pumpWidget(
          buildHarness(
            comparisonCubit: cubit,
            child: const SizedBox(
              width: 160,
              height: 200,
              child: PokemonCard(entry: _charmanderEntry, onTap: doNothing),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.compare_arrows_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(cubit.state.entries.length, equals(2));
        expect(cubit.isSelected(4), isFalse);
        expect(find.text('Comparison is full (2 max)'), findsOneWidget);
      });
    });

    testWidgets('long-press adds the entry to comparison', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = ComparisonCubit(_MockEnLogger());

        await tester.pumpWidget(
          buildHarness(
            comparisonCubit: cubit,
            child: const SizedBox(
              width: 160,
              height: 200,
              child: PokemonCard(entry: _bulbasaurEntry, onTap: doNothing),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.longPress(find.byType(PokemonCard));
        await tester.pumpAndSettle();

        expect(cubit.isSelected(1), isTrue);
      });
    });

    testWidgets(
      'compare button exposes accessible semantics and meets 48x48 dp touch target',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final cubit = ComparisonCubit(_MockEnLogger());

          Finder compareButton() => find.ancestor(
            of: find.byIcon(Icons.compare_arrows_rounded),
            matching: find.byType(IconButton),
          );

          await tester.pumpWidget(
            buildHarness(
              comparisonCubit: cubit,
              child: const SizedBox(
                width: 160,
                height: 200,
                child: PokemonCard(entry: _bulbasaurEntry, onTap: doNothing),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.bySemanticsLabel('Add to comparison'), findsOneWidget);
          expect(find.byTooltip('Add to comparison'), findsOneWidget);
          final addSize = tester.getSize(compareButton());
          expect(addSize.width, greaterThanOrEqualTo(48.0));
          expect(addSize.height, greaterThanOrEqualTo(48.0));

          await tester.tap(find.byIcon(Icons.compare_arrows_rounded));
          await tester.pumpAndSettle();

          expect(
            find.bySemanticsLabel('Remove from comparison'),
            findsOneWidget,
          );
          expect(find.byTooltip('Remove from comparison'), findsOneWidget);
          final removeSize = tester.getSize(compareButton());
          expect(removeSize.width, greaterThanOrEqualTo(48.0));
          expect(removeSize.height, greaterThanOrEqualTo(48.0));
        });
      },
    );
  });
}

void doNothing() {}
