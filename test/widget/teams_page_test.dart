import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/_app_bar.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/teams_list_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
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
const _charmanderEntry = PokemonIndexEntry(
  id: 4,
  name: 'charmander',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
  types: [PokemonType.fire],
);

void main() {
  late TestAppCubits cubits;
  late TeamsCubit teamsCubit;
  late _MockPokemonRepository repository;

  setUpAll(() async {
    // O11: build the DI graph, then inject a local mock repository so the
    // summary fetches of the team detail page never reach the network.
    registerFallbackValue(PokemonName('bulbasaur'));
    ensureHydratedStorage();
    repository = _MockPokemonRepository();
    await configureDependencies(Environment.dev);
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(repository);
  });

  setUp(() {
    HydratedBloc.storage = InMemoryHydratedStorage();
    reset(repository);
    when(
      () => repository.getPokemon(any()),
    ).thenAnswer((_) async => left(const NetworkUnavailableFailure('offline')));
    when(
      () => repository.getEncounters(any()),
    ).thenAnswer((_) async => const Right(<PokemonEncounter>[]));
    cubits = TestAppCubits(
      comparison: ComparisonCubit(_MockEnLogger(), repository),
    );
    teamsCubit = cubits.teams;
  });

  tearDown(() => cubits.close());

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

  /// Pumps [child] (the teams list by default), or [router] when given.
  Future<void> pumpTeams(
    WidgetTester tester, {
    GoRouter? router,
    Locale locale = const Locale('en'),
    Widget? child,
  }) {
    return tester.pumpApp(
      home: router == null ? child ?? const TeamsListPage() : null,
      router: router,
      cubits: cubits,
      locale: locale,
    );
  }

  GoRouter buildTeamsRouter({String initialLocation = AppRoutes.teams}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.teams,
          builder: (_, _) => const TeamsListPage(),
          routes: [
            GoRoute(
              path: ':teamId',
              builder: (_, state) =>
                  TeamDetailPage(teamId: state.pathParameters['teamId']!),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.pokedex,
          builder: (_, _) => const Scaffold(body: Text('Pokédex Browse')),
        ),
        GoRoute(
          path: '/pokemon/:nameOrId',
          builder: (_, state) => Scaffold(
            body: Text('Detail ${state.pathParameters['nameOrId']}'),
          ),
        ),
      ],
    );
  }

  group('TeamsListPage', () {
    testWidgets('renders empty state explaining how to build a team', (
      tester,
    ) async {
      await pumpTeams(tester);
      await tester.pumpAndSettle();

      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('No teams yet'), findsOneWidget);
      expect(
        find.text(
          'Create a team of up to 6 Pokémon to track type coverage and base stats.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'New team'), findsOneWidget);
    });

    testWidgets('localizes the empty state in Italian', (tester) async {
      await pumpTeams(tester, locale: const Locale('it'));
      await tester.pumpAndSettle();

      expect(find.text('Squadre'), findsOneWidget);
      expect(find.text('Nessuna squadra'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Nuova squadra'),
        findsOneWidget,
      );
    });

    testWidgets('create flow opens the team detail', (tester) async {
      await pumpTeams(tester, router: buildTeamsRouter());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'New team'));
      await tester.pumpAndSettle();

      expect(find.text('Create team'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Starters');
      await tester.tap(find.widgetWithText(ElevatedButton, 'New team').last);
      await tester.pumpAndSettle();

      expect(teamsCubit.state.teams.length, equals(1));
      expect(find.text('No members yet'), findsOneWidget);
    });

    testWidgets('create validates blank names', (tester) async {
      await pumpTeams(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'New team'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'New team').last);
      await tester.pump();

      expect(find.text('Enter a team name'), findsOneWidget);
      expect(teamsCubit.state.teams, isEmpty);
    });

    testWidgets('rename flow updates the team name', (tester) async {
      teamsCubit.createTeam('Old');
      await pumpTeams(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename team'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Rename team'));
      await tester.pumpAndSettle();

      expect(teamsCubit.state.teams.single.name, equals('New'));
    });

    testWidgets('delete flow asks for confirmation', (tester) async {
      teamsCubit.createTeam('Doomed');
      await pumpTeams(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete team'));
      await tester.pumpAndSettle();

      expect(find.text('Delete team?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete team'));
      await tester.pumpAndSettle();

      expect(teamsCubit.state.teams, isEmpty);
      expect(find.text('No teams yet'), findsOneWidget);
    });

    testWidgets('overflow menu uses the default show-menu tooltip', (
      tester,
    ) async {
      teamsCubit.createTeam('Team');
      await pumpTeams(tester);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Members'), findsNothing);
      expect(find.byTooltip('Show menu'), findsOneWidget);
    });
  });

  group('TeamDetailPage', () {
    testWidgets('renders members with summary and empty guidance', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Team summary'), findsOneWidget);
        expect(find.text('Type coverage'), findsOneWidget);
        expect(find.text('No members yet'), findsOneWidget);
        expect(
          find.text(
            'Add up to 6 Pokémon from the Pokédex cards or the detail screen.',
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets('member rows deep-link to the canonical detail route', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(ReorderableListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bulbasaur'));
        await tester.pumpAndSettle();

        expect(find.text('Detail bulbasaur'), findsOneWidget);
      });
    });

    testWidgets('duplicate members render a warning banner', (tester) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Duplicate Pokémon in team'), findsOneWidget);
        expect(
          find.text('This team contains the same Pokémon more than once.'),
          findsOneWidget,
        );
      });
    });

    testWidgets('remove flow drops the member', (tester) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        teamsCubit.addMember(teamId: teamId, pokemon: _charmanderEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(ReorderableListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Remove from team').first);
        await tester.pumpAndSettle();

        expect(teamsCubit.state.teamById(teamId)!.members.length, equals(1));
        expect(find.text('Bulbasaur'), findsNothing);
      });
    });

    testWidgets('stats summary renders summed and averaged totals', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(() => repository.getPokemon(any())).thenAnswer(
          (_) async => right(buildPokemon(id: 1, name: 'bulbasaur')),
        );
        when(
          () => repository.getEncounters(any()),
        ).thenAnswer((_) async => const Right(<PokemonEncounter>[]));
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Total (sum)'), findsOneWidget);
        expect(find.textContaining('Average'), findsOneWidget);
      });
    });

    testWidgets('a failing member fetch shows an inline retry row', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('bulbasaur'), findsWidgets);
        expect(find.byTooltip('Retry'), findsOneWidget);
      });
    });

    testWidgets('reordering members keeps the stats summary aligned', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, pokemon: _bulbasaurEntry.summary);
        teamsCubit.addMember(teamId: teamId, pokemon: _charmanderEntry.summary);
        await pumpTeams(
          tester,
          router: buildTeamsRouter(initialLocation: AppRoutes.team(teamId)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Type coverage'), findsOneWidget);
        await tester.drag(
          find.byType(ReorderableListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);

        teamsCubit.reorderMember(teamId, 0, 1);
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(ReorderableListView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(
          teamsCubit.state
              .teamById(teamId)!
              .members
              .map((m) => m.pokemon.name)
              .toList(),
          equals(['charmander', 'bulbasaur']),
        );
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);
        expect(find.text('Type coverage'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('detail app bar team action invokes the callback', (
      tester,
    ) async {
      var invoked = 0;
      await pumpTeams(
        tester,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              DetailAppBar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                expandedHeight: 200,
                background: const SizedBox.shrink(),
                onTeam: () => invoked++,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Add to team'), findsOneWidget);
      await tester.tap(find.byTooltip('Add to team'));
      await tester.pumpAndSettle();

      expect(invoked, equals(1));
    });
  });

  group('PokemonCard team action', () {
    Future<void> pumpCard(WidgetTester tester) {
      return pumpTeams(
        tester,
        child: const Scaffold(
          body: SizedBox(
            width: 300,
            height: 320,
            child: PokemonCard(entry: _bulbasaurEntry),
          ),
        ),
      );
    }

    testWidgets('the long-press sheet adds the entry and confirms', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        await pumpCard(tester);
        await settle(tester);

        await tester.longPress(find.byType(PokemonCard));
        await settle(tester);

        expect(find.text('Add to team'), findsOneWidget);

        await tester.tap(find.text('Add to team'));
        await settle(tester);

        expect(find.text('Choose a team'), findsOneWidget);
        await tester.tap(find.text('Team'));
        await settle(tester);

        expect(teamsCubit.state.teamById(teamId)!.members.length, equals(1));
        expect(find.text('Added to Team'), findsOneWidget);
      });
    });

    testWidgets('seventh member is rejected with guidance', (tester) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Full');
        for (var i = 1; i <= kTeamMaxMembers; i++) {
          teamsCubit.addMember(
            teamId: teamId,
            pokemon: PokemonSummary(id: i, name: 'pokemon-$i', spriteUrl: ''),
          );
        }
        await pumpCard(tester);
        await settle(tester);

        await tester.longPress(find.byType(PokemonCard));
        await settle(tester);

        await tester.tap(find.text('Add to team'));
        await settle(tester);
        await tester.tap(find.text('Full'));
        await settle(tester);

        expect(
          teamsCubit.state.teamById(teamId)!.members.length,
          equals(kTeamMaxMembers),
        );
        expect(find.text('Team is full (6 max)'), findsOneWidget);
      });
    });
  });
}
