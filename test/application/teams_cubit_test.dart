import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

const _bulbasaur = PokemonIndexEntry(
  id: 1,
  name: 'bulbasaur',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
  types: [PokemonType.grass, PokemonType.poison],
);
const _charmander = PokemonIndexEntry(
  id: 4,
  name: 'charmander',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
  types: [PokemonType.fire],
);
const _charizard = PokemonIndexEntry(
  id: 6,
  name: 'charizard',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/6/',
  types: [PokemonType.fire, PokemonType.flying],
);
const _charizardMegaX = PokemonIndexEntry(
  id: 6,
  name: 'charizard-mega-x',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/6/',
  types: [PokemonType.fire, PokemonType.dragon],
);

void main() {
  late _MockEnLogger logger;

  setUp(() {
    logger = _MockEnLogger();
    HydratedBloc.storage = InMemoryHydratedStorage();
  });

  TeamsCubit buildCubit({Clock? clock}) {
    return TeamsCubit(logger, clock: clock ?? const Clock());
  }

  group('TeamsCubit team CRUD', () {
    test('initial state has no teams', () {
      expect(buildCubit().state.teams, isEmpty);
    });

    test('createTeam stores a trimmed team and returns its id', () {
      final cubit = buildCubit();

      final id = cubit.createTeam('  Starters  ');

      expect(id, isNotEmpty);
      expect(cubit.state.teams.length, equals(1));
      expect(cubit.state.teams.single.name, equals('Starters'));
      expect(cubit.state.teamById(id)?.name, equals('Starters'));
    });

    test('createTeam rejects blank names', () {
      expect(() => buildCubit().createTeam('   '), throwsArgumentError);
    });

    test('createTeam truncates names beyond the max length', () {
      final cubit = buildCubit();
      final longName = List.filled(kTeamMaxNameLength + 10, 'a').join();

      final id = cubit.createTeam(longName);

      expect(cubit.state.teamById(id)?.name.length, equals(kTeamMaxNameLength));
    });

    test('renameTeam updates the name and rejects invalid input', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Old');

      expect(cubit.renameTeam(id, 'New'), isTrue);
      expect(cubit.state.teamById(id)?.name, equals('New'));
      expect(cubit.renameTeam(id, '   '), isFalse);
      expect(cubit.renameTeam('missing', 'New'), isFalse);
      expect(cubit.state.teamById(id)?.name, equals('New'));
    });

    test('deleteTeam removes only the matching team', () {
      final cubit = buildCubit();
      final first = cubit.createTeam('First');
      final second = cubit.createTeam('Second');

      expect(cubit.deleteTeam(first), isTrue);
      expect(
        cubit.state.teams.map((team) => team.id).toList(),
        equals([second]),
      );
      expect(cubit.deleteTeam(first), isFalse);
    });

    test('createTeam resolves id collisions deterministically', () {
      final fixed = DateTime.utc(2026, 1, 1);
      final cubit = buildCubit(clock: Clock.fixed(fixed));
      final first = cubit.createTeam('First');
      final second = cubit.createTeam('Second');

      expect(cubit.deleteTeam(first), isTrue);
      final third = cubit.createTeam('Third');

      expect(third, isNot(equals(second)));
      expect(cubit.state.teamById(third), isNotNull);
      expect(
        cubit.state.teams.map((team) => team.id).toSet().length,
        equals(2),
      );
    });
  });

  group('TeamsCubit members', () {
    test('addMember stores lightweight refs in order', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Team');

      expect(
        cubit.addMember(teamId: id, entry: _bulbasaur),
        equals(TeamAddMemberResult.added),
      );
      expect(
        cubit.addMember(teamId: id, entry: _charmander),
        equals(TeamAddMemberResult.added),
      );

      final members = cubit.state.teamById(id)!.members;
      expect(
        members.map((m) => m.name).toList(),
        equals(['bulbasaur', 'charmander']),
      );
      expect(members.first, isA<TeamMember>());
      expect(
        members.first.types,
        equals([PokemonType.grass, PokemonType.poison]),
      );
    });

    test('addMember to a missing team reports teamNotFound', () {
      expect(
        buildCubit().addMember(teamId: 'missing', entry: _bulbasaur),
        equals(TeamAddMemberResult.teamNotFound),
      );
    });

    test('six-member cap rejects the seventh member with guidance', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Full');
      for (var i = 1; i <= kTeamMaxMembers; i++) {
        final result = cubit.addMember(
          teamId: id,
          entry: PokemonIndexEntry(id: i, name: 'pokemon-$i', detailUrl: ''),
        );
        expect(result, equals(TeamAddMemberResult.added));
      }

      expect(
        cubit.addMember(teamId: id, entry: _bulbasaur),
        equals(TeamAddMemberResult.teamFull),
      );
      expect(cubit.state.teamById(id)!.members.length, equals(kTeamMaxMembers));
      expect(cubit.state.teamById(id)!.isFull, isTrue);
    });

    test('duplicate slugs warn but still add; forms stay distinct', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Team');
      cubit.addMember(teamId: id, entry: _charizard);

      expect(
        cubit.addMember(teamId: id, entry: _charizardMegaX),
        equals(TeamAddMemberResult.added),
      );
      expect(
        cubit.addMember(teamId: id, entry: _charizard),
        equals(TeamAddMemberResult.addedWithDuplicateWarning),
      );

      final members = cubit.state.teamById(id)!.members;
      expect(
        members.map((m) => m.name).toList(),
        equals(['charizard', 'charizard-mega-x', 'charizard']),
      );
      expect(TeamSummaryHelper.hasDuplicateMembers(members), isTrue);
    });

    test('removeMemberAt and removeMember drop members', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Team');
      cubit.addMember(teamId: id, entry: _bulbasaur);
      cubit.addMember(teamId: id, entry: _charmander);

      expect(cubit.removeMemberAt(id, 0), isTrue);
      expect(
        cubit.state.teamById(id)!.members.map((m) => m.name).toList(),
        equals(['charmander']),
      );
      expect(cubit.removeMember(id, 'CHARMANDER'), isTrue);
      expect(cubit.state.teamById(id)!.members, isEmpty);
      expect(cubit.removeMemberAt(id, 0), isFalse);
      expect(cubit.removeMember(id, 'missing'), isFalse);
    });

    test('reorderMember and moveMemberToTop rearrange members', () {
      final cubit = buildCubit();
      final id = cubit.createTeam('Team');
      cubit.addMember(teamId: id, entry: _bulbasaur);
      cubit.addMember(teamId: id, entry: _charmander);
      cubit.addMember(teamId: id, entry: _charizard);

      expect(cubit.reorderMember(id, 0, 2), isTrue);
      expect(
        cubit.state.teamById(id)!.members.map((m) => m.name).toList(),
        equals(['charmander', 'charizard', 'bulbasaur']),
      );
      expect(cubit.moveMemberToTop(id, 2), isTrue);
      expect(
        cubit.state.teamById(id)!.members.map((m) => m.name).toList(),
        equals(['bulbasaur', 'charmander', 'charizard']),
      );
      expect(cubit.reorderMember(id, 0, 5), isFalse);
      expect(cubit.reorderMember('missing', 0, 1), isFalse);
    });
  });

  group('TeamsCubit persistence', () {
    test('teams survive cubit restarts', () async {
      final cubit1 = buildCubit();
      final id = cubit1.createTeam('Persisted');
      cubit1.addMember(teamId: id, entry: _bulbasaur);
      await cubit1.close();

      final cubit2 = buildCubit();
      final restored = cubit2.state.teamById(id);
      expect(restored?.name, equals('Persisted'));
      expect(
        restored?.members.map((m) => m.name).toList(),
        equals(['bulbasaur']),
      );
    });

    test('corrupt team records are evicted without crashing', () {
      final cubit = buildCubit();

      final state = cubit.fromJson({
        'teams': [
          {
            'id': 'good',
            'name': 'Good',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
            'members': [
              {'id': 25, 'name': 'pikachu'},
              {'name': 'missing-id'},
            ],
          },
          {'name': 'missing-id'},
          {'id': 'blank-name', 'name': '  '},
          'not-a-map',
        ],
      });

      expect(state.teams.length, equals(1));
      expect(state.teams.single.id, equals('good'));
      expect(
        state.teams.single.members.map((m) => m.name).toList(),
        equals(['pikachu']),
      );
    });

    test('missing storage payload restores an empty state', () {
      expect(buildCubit().fromJson(const {}).teams, isEmpty);
    });

    test('type-corrupt payloads are evicted without throwing', () {
      final cubit = buildCubit();

      expect(cubit.fromJson({'teams': 'corrupt'}).teams, isEmpty);
      expect(cubit.fromJson({'teams': 123}).teams, isEmpty);

      final state = cubit.fromJson({
        'teams': [
          {
            'id': 'typed',
            'name': 'Typed',
            'createdAt': 123,
            'updatedAt': 123,
            'members': 'not-a-list',
          },
          {
            'id': 'bad-member',
            'name': 'BadMember',
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
            'members': [
              {
                'id': 25,
                'name': 'pikachu',
                'spriteUrl': 123,
                'types': 'not-a-list',
                'addedAt': 123,
              },
              {
                'id': 1,
                'name': 'bulbasaur',
                'types': [123, 'fire'],
              },
            ],
          },
        ],
      });

      expect(state.teams.length, equals(2));
      expect(state.teams.first.members, isEmpty);
      expect(
        state.teams.last.members.map((m) => m.name).toList(),
        equals(['pikachu', 'bulbasaur']),
      );
      expect(state.teams.last.members.first.spriteUrl, isEmpty);
      expect(state.teams.last.members.first.types, isEmpty);
      expect(state.teams.last.members.last.types, equals([PokemonType.fire]));
    });
  });
}
