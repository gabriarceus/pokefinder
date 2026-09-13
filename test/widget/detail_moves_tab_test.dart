import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/tabs/detail_moves_tab.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

void main() {
  setUpAll(() async {
    await configureDependencies('mock');
  });

  const sampleMoves = [
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
  ];

  final samplePokemon = buildPokemon(moves: sampleMoves);

  Widget createTestWidget({
    required DetailGameVersionCubit gameVersionCubit,
    Pokemon? pokemon,
  }) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: BlocProvider<DetailGameVersionCubit>.value(
            value: gameVersionCubit,
            child: DetailMovesTab(
              pokemon: pokemon ?? samplePokemon,
              textColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  group('DetailMovesTab Game Version Sync Tests', () {
    testWidgets(
      'renders internal game version selector dropdown when all versions is selected',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit();

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // Game selector label and dropdown should be visible
        expect(find.text('Game:'), findsOneWidget);
        expect(find.text('Diamond/Pearl'), findsOneWidget);
        expect(find.text('Tackle'), findsOneWidget);
      },
    );

    testWidgets(
      'hides internal dropdown and shows specific version moves when filtered by specific version',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit();
        gameVersionCubit.initialize(samplePokemon);
        gameVersionCubit.selectVersion('platinum');

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // Internal "Game:" label and dropdown should be hidden
        expect(find.text('Game:'), findsNothing);
        // Moves for platinum should be displayed
        expect(find.text('Quick Attack'), findsOneWidget);
        expect(find.text('Tackle'), findsNothing);
      },
    );

    testWidgets(
      'displays movesUnavailableForVersion when pokemon has no moves in selected game version',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit();
        gameVersionCubit.selectVersion('red');

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // Internal dropdown hidden
        expect(find.text('Game:'), findsNothing);
        // Unavailable notice displayed
        expect(
          find.text('No moves found for this game version.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'dynamically responds when gameVersionCubit changes from all to specific version and back',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit();

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // Initially on 'all'
        expect(find.text('Game:'), findsOneWidget);
        expect(find.text('Tackle'), findsOneWidget);

        // Switch to platinum
        gameVersionCubit.selectVersion('platinum');
        await tester.pumpAndSettle();

        expect(find.text('Game:'), findsNothing);
        expect(find.text('Quick Attack'), findsOneWidget);
        expect(find.text('Tackle'), findsNothing);

        // Switch back to all
        gameVersionCubit.selectVersion(DetailGameVersionState.allVersions);
        await tester.pumpAndSettle();

        expect(find.text('Game:'), findsOneWidget);
        expect(find.text('Tackle'), findsOneWidget);
      },
    );
  });
}
