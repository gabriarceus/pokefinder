import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/tabs/detail_moves_tab.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

void main() {
  setUpAll(() async {
    await configureDependencies(Environment.dev);
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
          // The tab body lives inside the page's NestedScrollView.
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ),
            ],
            body: BlocProvider<DetailGameVersionCubit>.value(
              value: gameVersionCubit,
              child: DetailMovesTab(pokemon: pokemon ?? samplePokemon),
            ),
          ),
        ),
      ),
    );
  }

  group('DetailMovesTab Game Version Sync Tests', () {
    testWidgets(
      'shows the shared game version selector when all versions is selected',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit()
          ..initialize(samplePokemon);

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // The single merged selector is shown next to the moves.
        expect(find.text('Game Version'), findsOneWidget);
        expect(find.text('All Versions'), findsOneWidget);
        // "All versions" resolves to the most recent version group.
        expect(find.text('Quick Attack'), findsOneWidget);
        expect(find.text('Tackle'), findsNothing);
      },
    );

    testWidgets(
      'keeps the selector visible and filters moves to the selected version',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit()
          ..initialize(samplePokemon);
        // 'diamond' belongs to the 'diamond-pearl' version group.
        gameVersionCubit.selectVersion('diamond');

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // The selector is no longer duplicated per tab, so it stays visible.
        expect(find.text('Game Version'), findsOneWidget);
        // Moves for the selected version group should be displayed
        expect(find.text('Tackle'), findsOneWidget);
        expect(find.text('Quick Attack'), findsNothing);
      },
    );

    testWidgets(
      'displays movesUnavailableForVersion when pokemon has no moves in selected game version',
      (tester) async {
        final gameVersionCubit = DetailGameVersionCubit()
          ..initialize(samplePokemon);
        gameVersionCubit.selectVersion('red');

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

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
        final gameVersionCubit = DetailGameVersionCubit()
          ..initialize(samplePokemon);

        await tester.pumpWidget(
          createTestWidget(gameVersionCubit: gameVersionCubit),
        );
        await tester.pumpAndSettle();

        // Initially on 'all'
        expect(find.text('All Versions'), findsOneWidget);
        expect(find.text('Quick Attack'), findsOneWidget);

        // Switch to diamond/pearl
        gameVersionCubit.selectVersion('diamond');
        await tester.pumpAndSettle();

        expect(find.text('Quick Attack'), findsNothing);
        expect(find.text('Tackle'), findsOneWidget);

        // Switch back to all
        gameVersionCubit.selectVersion(DetailGameVersionState.allVersions);
        await tester.pumpAndSettle();

        expect(find.text('All Versions'), findsOneWidget);
        expect(find.text('Quick Attack'), findsOneWidget);
      },
    );

    testWidgets('the search field filters the moves of the version group', (
      tester,
    ) async {
      final gameVersionCubit = DetailGameVersionCubit()
        ..initialize(samplePokemon);
      gameVersionCubit.selectVersion('diamond');

      await tester.pumpWidget(
        createTestWidget(gameVersionCubit: gameVersionCubit),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tackle'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nomatch');
      await tester.pumpAndSettle();

      expect(find.text('Tackle'), findsNothing);
      expect(find.text('No moves found for this game version.'), findsNothing);
    });
  });
}
