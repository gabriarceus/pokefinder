import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_game_version_selector.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../fixtures/pokemon_fixture.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await configureDependencies(Environment.dev);
  });

  Future<void> pumpTestWidget(
    WidgetTester tester, {
    required DetailGameVersionCubit cubit,
    Color typeColor = Colors.red,
  }) {
    return tester.pumpApp(
      home: Scaffold(
        body: BlocProvider<DetailGameVersionCubit>.value(
          value: cubit,
          child: DetailGameVersionSelector(typeColor: typeColor),
        ),
      ),
    );
  }

  group('DetailGameVersionSelector Widget Tests', () {
    testWidgets('renders nothing (shrink) when availableVersions is empty', (
      tester,
    ) async {
      final cubit = DetailGameVersionCubit();

      await pumpTestWidget(tester, cubit: cubit);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.text('Game Version'), findsNothing);
    });

    testWidgets(
      'renders dropdown with available versions and updates selection',
      (tester) async {
        final cubit = DetailGameVersionCubit();
        final samplePokemon = buildPokemon(
          moves: [
            const PokemonMove(
              name: 'thunderbolt',
              learnMethod: 'level-up',
              levelLearnedAt: 26,
              versionGroup: 'red-blue',
            ),
            const PokemonMove(
              name: 'thunder',
              learnMethod: 'level-up',
              levelLearnedAt: 41,
              versionGroup: 'yellow',
            ),
          ],
          heldItems: [
            const PokemonHeldItem(
              name: 'light-ball',
              rarity: 5,
              version: 'gold',
            ),
          ],
          gameIndices: ['silver'],
        );

        cubit.initialize(samplePokemon);

        await pumpTestWidget(tester, cubit: cubit);
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButton<String>), findsOneWidget);
        expect(find.text('Game Version'), findsOneWidget);
        expect(find.text('All Versions'), findsOneWidget);

        // Open dropdown
        await tester.tap(find.text('All Versions'));
        await tester.pumpAndSettle();

        // Find "Red" in dropdown menu and select it
        final redItem = find.text('Red').last;
        expect(redItem, findsOneWidget);
        await tester.tap(redItem);
        await tester.pumpAndSettle();

        expect(cubit.state.selectedVersion, 'red');
        expect(find.text('Red'), findsOneWidget);
      },
    );

    testWidgets('encounter versions are included in the available list', (
      tester,
    ) async {
      final cubit = DetailGameVersionCubit();
      final samplePokemon = buildPokemon(moves: const []);

      cubit.initialize(
        samplePokemon,
        encounters: const [
          PokemonEncounter(
            rawLocationAreaName: 'viridian-forest',
            versions: ['red', 'blue'],
          ),
        ],
      );

      await pumpTestWidget(tester, cubit: cubit);
      await tester.pumpAndSettle();

      expect(cubit.state.availableVersions, ['red', 'blue']);

      await tester.tap(find.text('All Versions'));
      await tester.pumpAndSettle();

      expect(find.text('Red').last, findsOneWidget);
      expect(find.text('Blue').last, findsOneWidget);
    });
  });
}
