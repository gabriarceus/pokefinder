import 'package:dartz/dartz.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_header.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repositories/mock_pokemon_repository.dart';
import '../fixtures/pokemon_fixture.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

class _MovesRepository extends MockPokemonRepository {
  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) async {
    return right(
      buildPokemon(
        speciesName: 'bulbasaur',
        moves: const [
          PokemonMove(
            name: 'tackle',
            levelLearnedAt: 1,
            learnMethod: 'level-up',
            versionGroup: 'diamond-pearl',
          ),
          PokemonMove(
            name: 'quick-attack',
            levelLearnedAt: 5,
            learnMethod: 'level-up',
            versionGroup: 'platinum',
          ),
        ],
      ),
    );
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  late IPokemonRepository originalRepository;

  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies(Environment.dev);
    originalRepository = getIt<IPokemonRepository>();
  });

  setUp(() {
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(_MovesRepository());
  });

  tearDown(() {
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(originalRepository);
  });

  testWidgets('the moves tab keeps its search query after a tab change', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpApp(
        router: createAppRouter(initialLocation: '/pokemon/bulbasaur'),
      );
      for (
        var i = 0;
        i < 50 && find.byType(DetailHeader).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await _pumpFrames(tester);

      await tester.tap(find.text('Moves'));
      await _pumpFrames(tester);
      await tester.enterText(find.byType(TextField), 'quick');
      await _pumpFrames(tester);
      expect(find.text('Tackle'), findsNothing);
      // A focused text field keeps its own page alive.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(find.text('Info'));
      await _pumpFrames(tester);
      await tester.tap(find.text('Moves'));
      await _pumpFrames(tester);

      expect(find.text('quick'), findsOneWidget);
      expect(find.text('Quick Attack'), findsOneWidget);
      expect(find.text('Tackle'), findsNothing);
    });
  });
}
