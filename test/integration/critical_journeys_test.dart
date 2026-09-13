import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/failure.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/form_selection_bottom_sheet.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/move_detail_bottom_sheet.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _InMemoryStorage implements Storage {
  final Map<String, dynamic> _entries = {};

  @override
  dynamic read(String key) => _entries[key];

  @override
  Future<void> write(String key, dynamic value) async => _entries[key] = value;

  @override
  Future<void> delete(String key) async => _entries.remove(key);

  @override
  Future<void> clear() async => _entries.clear();

  @override
  Future<void> close() async {}
}

const _megaForm = PokemonForm(
  name: 'venusaur-mega',
  url: 'https://pokeapi.co/api/v2/pokemon-form/10033/',
);

const _megaDetails = PokemonFormDetails(
  name: 'venusaur-mega',
  type1: PokemonType.grass,
  type2: PokemonType.poison,
  typeImage1: 'type_grass.png',
  typeImage2: 'type_poison.png',
  spriteDefault: 'mega.png',
  spriteShiny: 'mega_shiny.png',
  artworkDefault: 'mega_art.png',
  artworkShiny: 'mega_art_shiny.png',
);

const _tackleMoveDetail = MoveDetail(
  id: 33,
  name: 'tackle',
  accuracy: 100,
  power: 40,
  pp: 35,
  type: PokemonType.normal,
  damageClass: DamageClass.physical,
  flavorTexts: {
    'en': 'A physical attack in which the user charges and slams.',
    'it': 'Chi la usa carica e colpisce il bersaglio.',
  },
);

void main() {
  setUpAll(() {
    registerFallbackValue(PokemonName('pikachu'));
    registerFallbackValue(CancellationToken());
  });

  late _MockPokemonRepository repository;
  late _InMemoryStorage storage;

  setUp(() async {
    storage = _InMemoryStorage();
    HydratedBloc.storage = storage;

    await configureDependencies('mock');

    repository = _MockPokemonRepository();
    if (getIt.isRegistered<IPokemonRepository>()) {
      getIt.unregister<IPokemonRepository>();
    }
    getIt.registerSingleton<IPokemonRepository>(repository);

    // Default stubs
    when(() => repository.getAllPokemonNames()).thenAnswer(
      (_) async => const Right(['pikachu', 'bulbasaur', 'venusaur']),
    );
    when(() => repository.getPokemonIndex()).thenAnswer(
      (_) async => const Right([
        PokemonIndexEntry(id: 25, name: 'pikachu', detailUrl: ''),
        PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
        PokemonIndexEntry(id: 3, name: 'venusaur', detailUrl: ''),
      ]),
    );
    when(
      () => repository.getEncounters(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => repository.clearCache(),
    ).thenAnswer((_) async => const Right(unit));
    when(
      () => repository.getCacheSize(),
    ).thenAnswer((_) async => const Right(1024));
  });

  Future<void> pumpAppWithRouter(
    WidgetTester tester, {
    String initialLocation = '/',
  }) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await mockNetworkImagesFor(() async {
      final router = createAppRouter(initialLocation: initialLocation);
      await tester.pumpWidget(MyApp(router: router));
      await tester.pumpAndSettle();
    });
  }

  group('Journey 1: Valid search -> detail navigation', () {
    testWidgets('searches for valid pokemon and displays full detail view', (
      tester,
    ) async {
      final pikachu = buildPokemon(
        id: 25,
        name: 'pikachu',
        type1: PokemonType.electric,
      );
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(pikachu));

      await pumpAppWithRouter(tester, initialLocation: '/');

      expect(find.byType(HomePage), findsOneWidget);

      // Enter search query
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'pikachu');
      await tester.pumpAndSettle();

      // Tap search button
      final searchButtonFinder = find.widgetWithText(ElevatedButton, 'Search');
      expect(searchButtonFinder, findsOneWidget);
      await mockNetworkImagesFor(() async {
        await tester.tap(searchButtonFinder, warnIfMissed: false);
        await tester.pumpAndSettle();
      });

      // Verify navigation to Detail page
      expect(find.byType(Detail), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('#025'), findsOneWidget);
      expect(
        getIt<RecentHistoryCubit>().state.recentSearches,
        contains('pikachu'),
      );
    });
  });

  group('Journey 2: Unknown Pokémon -> not found -> edit/retry', () {
    testWidgets(
      'not found failure displays recovery UI and allows edit search back to home',
      (tester) async {
        when(
          () => repository.getPokemon(
            any(),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => Left(PokemonNotFoundFailure()));

        await pumpAppWithRouter(tester, initialLocation: '/');

        // Enter unknown Pokémon in search and submit
        await tester.enterText(find.byType(TextField), 'missingno');
        await tester.pumpAndSettle();

        final searchButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Search',
        );
        await mockNetworkImagesFor(() async {
          await tester.tap(searchButtonFinder);
          await tester.pumpAndSettle();
        });

        // Verify not found failure page is rendered
        expect(find.byType(DetailFailure), findsOneWidget);
        expect(find.text('Pokémon not found.'), findsOneWidget);
        expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);

        // Tap Edit Search
        final editSearchBtn = find.widgetWithText(
          OutlinedButton,
          'Edit Search',
        );
        expect(editSearchBtn, findsOneWidget);
        await tester.tap(editSearchBtn);
        await tester.pumpAndSettle();

        // Verifies return to HomePage with query preserved in text controller
        expect(find.byType(HomePage), findsOneWidget);
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'missingno');
        expect(getIt<RecentHistoryCubit>().state.recentSearches, isEmpty);
      },
    );

    testWidgets('not found failure allows retrying fetch directly', (
      tester,
    ) async {
      var callCount = 0;
      final pokemon = buildPokemon(id: 25, name: 'pikachu');
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return callCount == 1 ? Left(PokemonNotFoundFailure()) : Right(pokemon);
      });

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/pikachu');

      expect(find.byType(DetailFailure), findsOneWidget);

      // Tap Retry
      final retryBtn = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryBtn, findsOneWidget);
      await mockNetworkImagesFor(() async {
        await tester.tap(retryBtn);
        await tester.pumpAndSettle();
      });

      // Verifies successful recovery on retry
      expect(find.byType(Detail), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
    });
  });

  group('Journey 3: Offline cached Pokémon inspection', () {
    testWidgets('displays cached Pokémon with stale indicator when offline', (
      tester,
    ) async {
      final cachedBulbasaur = buildPokemon(
        id: 1,
        name: 'bulbasaur',
        isStale: true,
      );
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(cachedBulbasaur));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/bulbasaur');

      expect(find.byType(Detail), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets(
      'displays offline error state when uncached Pokémon is searched offline',
      (tester) async {
        when(
          () => repository.getPokemon(
            any(),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Left(NetworkUnavailableFailure()));

        await pumpAppWithRouter(tester, initialLocation: '/pokemon/mew');

        expect(find.byType(DetailFailure), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
        expect(
          find.text('No internet connection. Please check your network.'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
      },
    );
  });

  group('Journey 4: Direct /pokemon/:nameOrId route navigation', () {
    testWidgets('direct route with name resolves to Detail', (tester) async {
      final bulbasaur = buildPokemon(id: 1, name: 'bulbasaur');
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(bulbasaur));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/bulbasaur');

      expect(find.byType(Detail), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
    });

    testWidgets('direct route with numeric ID resolves to Detail', (
      tester,
    ) async {
      final pikachu = buildPokemon(id: 25, name: 'pikachu');
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(pikachu));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/25');

      expect(find.byType(Detail), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
    });

    testWidgets(
      'direct route with malformed id renders RouteErrorPage and returns home',
      (tester) async {
        await pumpAppWithRouter(
          tester,
          initialLocation: '/pokemon/invalid!name',
        );

        expect(find.byType(RouteErrorPage), findsOneWidget);

        final returnHomeBtn = find.widgetWithText(ElevatedButton, 'Go to Home');
        expect(returnHomeBtn, findsOneWidget);
        await tester.tap(returnHomeBtn);
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );
  });

  group('Journey 5: Alternate form selection and rollback on failure', () {
    testWidgets('selects alternate form successfully', (tester) async {
      final venusaur = buildPokemon(
        id: 3,
        name: 'venusaur',
        forms: [
          const PokemonForm(name: 'venusaur', url: 'form/3/'),
          _megaForm,
        ],
      );
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(venusaur));
      when(
        () => repository.getFormDetails(
          _megaForm.url,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Right(_megaDetails));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/venusaur');

      // Find and tap Select Form & Appearance button in Info tab
      final formsButton = find.widgetWithText(
        FilledButton,
        'Select Form & Appearance',
      );
      expect(formsButton, findsOneWidget);
      await tester.tap(formsButton);
      await tester.pumpAndSettle();

      expect(find.byType(FormSelectionBottomSheet), findsOneWidget);

      // Select mega form
      final megaTile = find.descendant(
        of: find.byType(FormSelectionBottomSheet),
        matching: find.widgetWithText(InkWell, 'Venusaur - Mega'),
      );
      expect(megaTile, findsOneWidget);
      await mockNetworkImagesFor(() async {
        await tester.tap(megaTile);
        await tester.pumpAndSettle();
      });

      // Detail header now reflects the selected form name
      expect(
        find.descendant(
          of: find.byType(DetailHeader),
          matching: find.text('Venusaur - Mega'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('rolls back and shows failure message on form load error', (
      tester,
    ) async {
      final venusaur = buildPokemon(
        id: 3,
        name: 'venusaur',
        forms: [
          const PokemonForm(name: 'venusaur', url: 'form/3/'),
          _megaForm,
        ],
      );
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(venusaur));
      when(
        () => repository.getFormDetails(
          _megaForm.url,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Left(UnexpectedFailure('Form failed')));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/venusaur');

      final formsButton = find.widgetWithText(
        FilledButton,
        'Select Form & Appearance',
      );
      await tester.tap(formsButton);
      await tester.pumpAndSettle();

      final megaTile = find.descendant(
        of: find.byType(FormSelectionBottomSheet),
        matching: find.widgetWithText(InkWell, 'Venusaur - Mega'),
      );
      await tester.tap(megaTile);
      await tester.pumpAndSettle();

      // Verifies failure notice and rollback action are displayed in bottom sheet
      final rollbackFinder = find.text('Reset to default form');
      expect(rollbackFinder, findsOneWidget);
      expect(find.text('Venusaur'), findsWidgets);

      // Triggers rollback action and verifies failure notice is dismissed
      await tester.tap(rollbackFinder);
      await tester.pumpAndSettle();
      expect(find.text('Reset to default form'), findsNothing);
    });
  });

  group('Journey 6: Move detail success and failure', () {
    testWidgets('opens move detail bottom sheet with full move info', (
      tester,
    ) async {
      final bulbasaur = buildPokemon(
        id: 1,
        name: 'bulbasaur',
        moves: const [
          PokemonMove(
            name: 'tackle',
            levelLearnedAt: 1,
            learnMethod: 'level-up',
            versionGroup: 'red-blue',
          ),
        ],
      );
      when(
        () => repository.getPokemon(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(bulbasaur));
      when(
        () => repository.getMoveDetail('tackle'),
      ).thenAnswer((_) async => const Right(_tackleMoveDetail));

      await pumpAppWithRouter(tester, initialLocation: '/pokemon/bulbasaur');

      // Switch to Moves tab
      final movesTab = find.text('Moves');
      expect(movesTab, findsOneWidget);
      await tester.tap(movesTab);
      await tester.pumpAndSettle();

      // Tap Tackle move
      final tackleCard = find.widgetWithText(ListTile, 'Tackle');
      expect(tackleCard, findsOneWidget);
      await tester.tap(tackleCard);
      await tester.pumpAndSettle();

      expect(find.byType(MoveDetailBottomSheet), findsOneWidget);
      expect(find.text('Power'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
    });

    testWidgets(
      'move detail failure shows retry button and succeeds on retry',
      (tester) async {
        final bulbasaur = buildPokemon(
          id: 1,
          name: 'bulbasaur',
          moves: const [
            PokemonMove(
              name: 'tackle',
              levelLearnedAt: 1,
              learnMethod: 'level-up',
              versionGroup: 'red-blue',
            ),
          ],
        );
        when(
          () => repository.getPokemon(
            any(),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => Right(bulbasaur));

        var moveCalls = 0;
        when(() => repository.getMoveDetail('tackle')).thenAnswer((_) async {
          moveCalls++;
          return moveCalls == 1
              ? const Left(NetworkUnavailableFailure())
              : const Right(_tackleMoveDetail);
        });

        await pumpAppWithRouter(tester, initialLocation: '/pokemon/bulbasaur');

        await tester.tap(find.text('Moves'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ListTile, 'Tackle'));
        await tester.pumpAndSettle();

        // Verify failure state in sheet
        expect(
          find.text('No internet connection. Please check your network.'),
          findsOneWidget,
        );

        // Tap Retry
        final retryBtn = find.widgetWithText(OutlinedButton, 'Retry');
        expect(retryBtn, findsOneWidget);
        await tester.tap(retryBtn);
        await tester.pumpAndSettle();

        // Verifies recovery
        expect(find.text('Power'), findsOneWidget);
        expect(find.text('40'), findsOneWidget);
      },
    );
  });

  group('Journey 7: Language persistence across restart', () {
    testWidgets('updates UI language and persists across application restart', (
      tester,
    ) async {
      await pumpAppWithRouter(tester, initialLocation: '/');

      expect(find.text('PokéFinder'), findsOneWidget);

      // Open drawer menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Disable 'Use device language' switch
      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);
      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      // Tap 'Italiano' language radio option
      final italianOption = find.widgetWithText(RadioListTile<int>, 'Italiano');
      expect(italianOption, findsOneWidget);
      await tester.tap(italianOption);
      await tester.pumpAndSettle();

      // Close drawer
      final navigator = Navigator.of(tester.element(find.byType(Drawer)));
      navigator.pop();
      await tester.pumpAndSettle();

      // Verifies home page is now in Italian
      expect(find.text('Cerca Pokémon'), findsOneWidget);
      expect(find.text('Cerca'), findsOneWidget);

      // Simulate app restart: mount a brand-new router and widget tree using same Hydrated storage
      await mockNetworkImagesFor(() async {
        final freshRouter = createAppRouter(initialLocation: '/');
        await tester.pumpWidget(MyApp(router: freshRouter));
        await tester.pumpAndSettle();
      });

      // Verifies language choice persisted into the fresh app instance
      expect(find.text('Cerca Pokémon'), findsOneWidget);
    });
  });

  group('Journey 8: Cache clear success and failure', () {
    testWidgets('clearing cache successfully shows confirmation snackbar', (
      tester,
    ) async {
      when(
        () => repository.clearCache(),
      ).thenAnswer((_) async => const Right(unit));

      await pumpAppWithRouter(tester, initialLocation: '/');

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Clear Cache
      final clearCacheBtn = find.widgetWithText(ElevatedButton, 'Clear cache');
      expect(clearCacheBtn, findsOneWidget);
      await tester.tap(clearCacheBtn);
      await tester.pumpAndSettle();

      final confirmBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Clear'),
      );
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();
      }

      // Verifies drawer closed and a single success snackbar displayed
      expect(find.byType(Drawer), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Cache cleared successfully'), findsOneWidget);
    });

    testWidgets(
      'cache clearing error displays localized storage failure snackbar',
      (tester) async {
        when(() => repository.clearCache()).thenAnswer(
          (_) async => const Left(StorageFailure('Corrupt storage')),
        );

        await pumpAppWithRouter(tester, initialLocation: '/');

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        final clearCacheBtn = find.widgetWithText(
          ElevatedButton,
          'Clear cache',
        );
        await tester.tap(clearCacheBtn);
        await tester.pumpAndSettle();

        final confirmBtn = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'Clear'),
        );
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn);
          await tester.pumpAndSettle();
        }

        expect(find.byType(Drawer), findsNothing);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('A storage error occurred. Please try again.'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
