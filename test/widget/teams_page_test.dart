import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/_app_bar.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/teams_list_page.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

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
  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies('mock');
  });

  late TeamsCubit teamsCubit;

  setUp(() {
    HydratedBloc.storage = InMemoryHydratedStorage();
    teamsCubit = TeamsCubit(_MockEnLogger());
  });

  tearDown(() {
    teamsCubit.close();
  });

  Widget buildListHarness({
    GoRouter? router,
    Locale locale = const Locale('en'),
  }) {
    if (router != null) {
      return BlocProvider<TeamsCubit>.value(
        value: teamsCubit,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
        ),
      );
    }
    return BlocProvider<TeamsCubit>.value(
      value: teamsCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const TeamsListPage(),
      ),
    );
  }

  GoRouter buildTeamsRouter({String initialLocation = '/teams'}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/teams',
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
          path: '/pokedex',
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
      await tester.pumpWidget(buildListHarness());
      await tester.pumpAndSettle();

      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('No teams yet'), findsOneWidget);
      expect(
        find.text(
          'Create a team of up to 6 Pokémon to track type coverage and base stats.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(ElevatedButton, 'New team'), findsOneWidget);
    });

    testWidgets('localizes the empty state in Italian', (tester) async {
      await tester.pumpWidget(buildListHarness(locale: const Locale('it')));
      await tester.pumpAndSettle();

      expect(find.text('Squadre'), findsOneWidget);
      expect(find.text('Nessuna squadra'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Nuova squadra'),
        findsOneWidget,
      );
    });

    testWidgets('create flow opens the team detail', (tester) async {
      await tester.pumpWidget(buildListHarness(router: buildTeamsRouter()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'New team'));
      await tester.pumpAndSettle();

      expect(find.text('Create team'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Starters');
      await tester.tap(find.widgetWithText(ElevatedButton, 'New team').last);
      await tester.pumpAndSettle();

      expect(teamsCubit.state.teams.length, equals(1));
      expect(find.text('No members yet'), findsOneWidget);
    });

    testWidgets('create validates blank names', (tester) async {
      await tester.pumpWidget(buildListHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'New team'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'New team').last);
      await tester.pump();

      expect(find.text('Enter a team name'), findsOneWidget);
      expect(teamsCubit.state.teams, isEmpty);
    });

    testWidgets('rename flow updates the team name', (tester) async {
      teamsCubit.createTeam('Old');
      await tester.pumpWidget(buildListHarness());
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
      await tester.pumpWidget(buildListHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete team'));
      await tester.pumpAndSettle();

      expect(find.text('Delete team?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete team'));
      await tester.pumpAndSettle();

      expect(teamsCubit.state.teams, isEmpty);
      expect(find.text('No teams yet'), findsOneWidget);
    });

    testWidgets('overflow menu uses the default show-menu tooltip', (
      tester,
    ) async {
      teamsCubit.createTeam('Team');
      await tester.pumpWidget(buildListHarness());
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
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
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
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
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
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
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
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        teamsCubit.addMember(teamId: teamId, entry: _charmanderEntry);
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
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
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Total (sum)'), findsOneWidget);
        expect(find.textContaining('Average'), findsOneWidget);
      });
    });

    testWidgets('reordering members keeps the stats summary aligned', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        teamsCubit.addMember(teamId: teamId, entry: _bulbasaurEntry);
        teamsCubit.addMember(teamId: teamId, entry: _charmanderEntry);
        await tester.pumpWidget(
          buildListHarness(
            router: buildTeamsRouter(initialLocation: '/teams/$teamId'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Total (sum)'), findsOneWidget);
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
              .map((m) => m.name)
              .toList(),
          equals(['charmander', 'bulbasaur']),
        );
        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Charmander'), findsOneWidget);
        expect(find.textContaining('Total (sum)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('detail app bar team action invokes the callback', (
      tester,
    ) async {
      var invoked = 0;
      await tester.pumpWidget(
        BlocProvider<TeamsCubit>.value(
          value: teamsCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: DetailAppBar(
                backgroundColor: Colors.green,
                onTeam: () => invoked++,
              ),
            ),
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
    Widget buildCardHarness() {
      return BlocProvider<TeamsCubit>.value(
        value: teamsCubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 320,
              child: PokemonCard(entry: _bulbasaurEntry, onTap: () {}),
            ),
          ),
        ),
      );
    }

    testWidgets('tapping the team action adds the entry and confirms', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final teamId = teamsCubit.createTeam('Team');
        await tester.pumpWidget(buildCardHarness());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.group_add_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Choose a team'), findsOneWidget);
        await tester.tap(find.text('Team'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

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
            entry: PokemonIndexEntry(id: i, name: 'pokemon-$i', detailUrl: ''),
          );
        }
        await tester.pumpWidget(buildCardHarness());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.group_add_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Full'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          teamsCubit.state.teamById(teamId)!.members.length,
          equals(kTeamMaxMembers),
        );
        expect(find.text('Team is full (6 max)'), findsOneWidget);
      });
    });

    testWidgets('team button exposes accessible semantics and 48dp target', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildCardHarness());
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Add to team'), findsOneWidget);
        expect(find.byTooltip('Add to team'), findsOneWidget);
        final size = tester.getSize(
          find.ancestor(
            of: find.byIcon(Icons.group_add_rounded),
            matching: find.byType(IconButton),
          ),
        );
        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      });
    });
  });
}
