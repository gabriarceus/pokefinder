import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/sprite_box_image.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

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
const _missingNoEntry = PokemonIndexEntry(
  id: 999,
  name: 'missingno',
  detailUrl: '',
);

void main() {
  late _MockEnLogger logger;
  late _MockPokemonRepository repository;

  setUpAll(() {
    // ComparisonCubit takes a PokemonName and PokemonCard reads the hydrated
    // FavoritesCubit.
    registerFallbackValue(PokemonName('bulbasaur'));
    HydratedBloc.storage = InMemoryHydratedStorage();
  });

  setUp(() {
    logger = _MockEnLogger();
    repository = _MockPokemonRepository();
    // The image cache is global: drop sprites resolved by earlier tests so a
    // deliberately unmocked request really fails again.
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });

  /// Resolves [name] to a small deterministic Pokémon so the page has real
  /// details to render; unknown names fail.
  void stubDetails() {
    when(() => repository.getPokemon(any())).thenAnswer((invocation) {
      final name = (invocation.positionalArguments.first as PokemonName)
          .rightOrCrash();
      return switch (name) {
        'bulbasaur' => Future.value(
          right(
            buildPokemon(
              id: 1,
              name: 'bulbasaur',
              type1: PokemonType.grass,
              type2: PokemonType.poison,
            ),
          ),
        ),
        'pikachu' => Future.value(
          right(
            buildPokemon(
              id: 25,
              name: 'pikachu',
              type1: PokemonType.electric,
              type2: null,
            ),
          ),
        ),
        'charmander' => Future.value(
          right(
            buildPokemon(
              id: 4,
              name: 'charmander',
              type1: PokemonType.fire,
              type2: null,
            ),
          ),
        ),
        _ => Future.value(left(const PokemonNotFoundFailure())),
      };
    });
  }

  ComparisonCubit buildComparisonCubit() {
    stubDetails();
    return ComparisonCubit(logger, repository);
  }

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

  /// Pumps [child] in a scaffold, with [comparisonCubit] as the app's
  /// comparison cubit.
  Future<void> pumpHarness(
    WidgetTester tester, {
    required ComparisonCubit comparisonCubit,
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    final cubits = TestAppCubits(comparison: comparisonCubit);
    addTearDown(cubits.close);
    return tester.pumpApp(
      home: Scaffold(body: child),
      cubits: cubits,
      locale: locale,
    );
  }

  group('ComparisonPage empty state', () {
    testWidgets('explains how to add entries', (tester) async {
      final cubit = buildComparisonCubit();

      await pumpHarness(
        tester,
        comparisonCubit: cubit,
        child: const ComparisonPage(),
      );
      await settle(tester);

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
      final cubit = buildComparisonCubit();

      await pumpHarness(
        tester,
        comparisonCubit: cubit,
        child: const ComparisonPage(),
        locale: const Locale('it'),
      );
      await settle(tester);

      expect(find.text('Nessun Pokémon da confrontare'), findsOneWidget);
      expect(find.text('Esplora Pokédex'), findsOneWidget);
    });
  });

  group('ComparisonPage add/remove/clear flows', () {
    testWidgets('renders two entries with aligned stat rows', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit()
          ..addEntry(_bulbasaurEntry.summary)
          ..addEntry(_pikachuEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const ComparisonPage(),
        );
        await settle(tester);

        expect(find.text('Compare'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        // Single shared stat section driven by buildComparisonStatRows.
        expect(find.text('Base Stats'), findsOneWidget);
        // Aligned rows expose both sides in one semantics node.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == 'HP: 45, 45',
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

        final cubit = buildComparisonCubit()
          ..addEntry(_bulbasaurEntry.summary)
          ..addEntry(_pikachuEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const ComparisonPage(),
        );
        await settle(tester);

        // Both sides remain visible with a single shared stat table.
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Base Stats'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == 'HP: 45, 45',
          ),
          findsOneWidget,
        );
        expect(find.text('318'), findsNWidgets(2));
      });
    });

    testWidgets('renders placeholder icon when sprite URL is empty', (
      tester,
    ) async {
      when(
        () => repository.getPokemon(any()),
      ).thenAnswer((_) async => right(buildPokemon(sprite: '')));
      final cubit = ComparisonCubit(logger, repository)
        ..addEntry(_bulbasaurEntry.summary);

      await pumpHarness(
        tester,
        comparisonCubit: cubit,
        child: const ComparisonPage(),
      );
      await settle(tester);

      expect(find.text('Bulbasaur'), findsOneWidget);
      // The sprite box must resolve an unloadable image to a placeholder icon,
      // never to a raw hole or an exception.
      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(SpriteBoxImage),
          matching: find.byType(Image),
        ),
      );
      final context = tester.element(find.byType(SpriteBoxImage));
      expect(image.errorBuilder, isNotNull);
      await tester.pumpWidget(
        MaterialApp(
          home: image.errorBuilder!(context, Exception('failure'), null),
        ),
      );
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('a single entry shows the empty second slot', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit()..addEntry(_bulbasaurEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const ComparisonPage(),
        );
        await settle(tester);

        expect(find.text('Add a second Pokémon to compare'), findsOneWidget);
        // A single loaded Pokémon renders its own stat rows plus a total.
        expect(find.text('Base Stats'), findsOneWidget);
        expect(find.text('Total: 318'), findsOneWidget);
        expect(find.byTooltip('Remove from comparison'), findsOneWidget);
      });
    });

    testWidgets('remove-one keeps the other side, clear-all empties', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit()
          ..addEntry(_bulbasaurEntry.summary)
          ..addEntry(_pikachuEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const ComparisonPage(),
        );
        await settle(tester);

        await tester.tap(find.byTooltip('Remove from comparison').first);
        await settle(tester);

        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Bulbasaur'), findsNothing);
        expect(find.text('Add a second Pokémon to compare'), findsOneWidget);

        await tester.tap(find.byTooltip('Clear comparison'));
        await settle(tester);

        expect(find.text('No Pokémon to compare'), findsOneWidget);
        expect(cubit.state.entries, isEmpty);
      });
    });
  });

  group('ComparisonPage per-entry detail states', () {
    testWidgets(
      'a failed entry shows retry without destroying the valid side',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final cubit = buildComparisonCubit()
            ..addEntry(_missingNoEntry.summary)
            ..addEntry(_charmanderEntry.summary);

          await pumpHarness(
            tester,
            comparisonCubit: cubit,
            child: const ComparisonPage(),
          );
          await settle(tester);

          expect(find.text('Pokémon not found.'), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
          expect(find.text('Charmander'), findsOneWidget);
          expect(find.text('Base Stats'), findsOneWidget);

          await tester.tap(find.text('Retry'));
          await settle(tester);

          verify(() => repository.getPokemon(any())).called(3);
          expect(find.text('Pokémon not found.'), findsOneWidget);
          expect(find.text('Charmander'), findsOneWidget);
        });
      },
    );

    testWidgets('an entry still loading shows a progress indicator', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final pending = Completer<Either<PokemonFailure, Pokemon>>();
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) => pending.future);
        final cubit = ComparisonCubit(logger, repository)
          ..addEntry(_bulbasaurEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const ComparisonPage(),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Bulbasaur'), findsOneWidget);

        pending.complete(right(buildPokemon()));
        await settle(tester);

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Base Stats'), findsOneWidget);
      });
    });
  });

  group('PokemonCard compare action', () {
    testWidgets('the long-press sheet adds the entry to comparison', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit();

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const SizedBox(
            width: 160,
            height: 200,
            child: PokemonCard(entry: _bulbasaurEntry),
          ),
        );
        await settle(tester);

        await tester.longPress(find.byType(PokemonCard));
        await settle(tester);

        expect(find.text('Add to comparison'), findsOneWidget);

        await tester.tap(find.text('Add to comparison'));
        await settle(tester);

        expect(cubit.isSelected(1), isTrue);
        expect(find.text('Added to comparison'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Added to comparison'), findsNothing);
      });
    });

    testWidgets('the sheet removes an already selected entry', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit()..addEntry(_bulbasaurEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const SizedBox(
            width: 160,
            height: 200,
            child: PokemonCard(entry: _bulbasaurEntry),
          ),
        );
        await settle(tester);

        await tester.longPress(find.byType(PokemonCard));
        await settle(tester);

        expect(find.text('Remove from comparison'), findsOneWidget);

        await tester.tap(find.text('Remove from comparison'));
        await settle(tester);

        expect(cubit.isSelected(1), isFalse);
      });
    });

    testWidgets('third entry is refused with a full message', (tester) async {
      await mockNetworkImagesFor(() async {
        final cubit = buildComparisonCubit()
          ..addEntry(_bulbasaurEntry.summary)
          ..addEntry(_pikachuEntry.summary);

        await pumpHarness(
          tester,
          comparisonCubit: cubit,
          child: const SizedBox(
            width: 160,
            height: 200,
            child: PokemonCard(entry: _charmanderEntry),
          ),
        );
        await settle(tester);

        await tester.longPress(find.byType(PokemonCard));
        await settle(tester);

        await tester.tap(find.text('Add to comparison'));
        await settle(tester);

        expect(cubit.state.entries.length, equals(2));
        expect(cubit.isSelected(4), isFalse);
        expect(find.text('Comparison is full (2 max)'), findsOneWidget);
      });
    });
  });
}
