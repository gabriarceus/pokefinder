import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_game_version_selector.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../fixtures/pokemon_fixture.dart';

void main() {
  setUpAll(() async {
    await configureDependencies('mock');
  });

  Widget createTestWidget({
    required DetailGameVersionCubit cubit,
    Color typeColor = Colors.red,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

      await tester.pumpWidget(createTestWidget(cubit: cubit));
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

        await tester.pumpWidget(createTestWidget(cubit: cubit));
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
  });
}
