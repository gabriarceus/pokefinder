import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

TeamMember _member({
  int id = 25,
  String name = 'pikachu',
  List<PokemonType> types = const [PokemonType.electric],
}) {
  return TeamMember(
    pokemon: PokemonSummary(
      id: id,
      name: name,
      spriteUrl: 'https://example.com/$id.png',
      types: types,
    ),
    addedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('TeamMember', () {
    test('round-trips through JSON', () {
      final member = _member();
      final restored = TeamMember.fromJson(member.toJson());

      expect(restored, equals(member));
    });

    test('memberKey normalizes slugs for identity', () {
      final member = _member(name: 'Charizard-Mega-X');

      expect(member.memberKey, equals('charizard-mega-x'));
    });

    test('fromJson throws on missing id or blank name', () {
      expect(
        () => TeamMember.fromJson({'name': 'pikachu'}),
        throwsFormatException,
      );
      expect(
        () => TeamMember.fromJson({'id': 25, 'name': '  '}),
        throwsFormatException,
      );
      expect(
        () => TeamMember.fromJson({'id': 0, 'name': 'pikachu'}),
        throwsFormatException,
      );
    });

    test('fromJson drops unknown types instead of crashing', () {
      final restored = TeamMember.fromJson({
        'id': 25,
        'name': 'pikachu',
        'spriteUrl': '',
        'types': ['electric', 'not-a-type'],
        'addedAt': '2026-01-01T00:00:00.000Z',
      });

      expect(restored.pokemon.types, equals([PokemonType.electric]));
    });

    test('toIndexEntry carries the lightweight ref', () {
      final entry = _member().pokemon.toIndexEntry();

      expect(entry.id, equals(25));
      expect(entry.name, equals('pikachu'));
      expect(entry.types, equals([PokemonType.electric]));
    });
  });

  group('PokemonTeam', () {
    test('round-trips through JSON', () {
      final team = PokemonTeam(
        id: 'team-1',
        name: 'Starters',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
        members: [
          _member(),
          _member(id: 1, name: 'bulbasaur'),
        ],
      );

      expect(PokemonTeam.fromJson(team.toJson()), equals(team));
    });

    test('fromJson throws on missing team identity', () {
      expect(
        () => PokemonTeam.fromJson({'name': 'Starters'}),
        throwsFormatException,
      );
      expect(
        () => PokemonTeam.fromJson({'id': 'team-1', 'name': '  '}),
        throwsFormatException,
      );
    });

    test('fromJson skips corrupt members without crashing', () {
      final team = PokemonTeam.fromJson({
        'id': 'team-1',
        'name': 'Starters',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-02T00:00:00.000Z',
        'members': [
          {'id': 25, 'name': 'pikachu'},
          {'name': 'missing-id'},
          {'id': 1, 'name': ''},
          'not-a-map',
        ],
      });

      expect(
        team.members.map((m) => m.pokemon.name).toList(),
        equals(['pikachu']),
      );
    });

    test('fromJson tolerates wrong field types without throwing', () {
      final team = PokemonTeam.fromJson({
        'id': 'team-1',
        'name': 'Starters',
        'createdAt': 123,
        'updatedAt': 123,
        'members': 'not-a-list',
      });
      expect(team.members, isEmpty);

      final member = TeamMember.fromJson({
        'id': 25,
        'name': 'pikachu',
        'spriteUrl': 123,
        'types': 'not-a-list',
        'addedAt': 123,
      });
      expect(member.pokemon.spriteUrl, isEmpty);
      expect(member.pokemon.types, isEmpty);
    });

    test('fromJson truncates members beyond the 6-member cap', () {
      final team = PokemonTeam.fromJson({
        'id': 'team-1',
        'name': 'Oversized',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'members': [
          for (var i = 1; i <= 8; i++) {'id': i, 'name': 'pokemon-$i'},
        ],
      });

      expect(team.members.length, equals(kTeamMaxMembers));
    });

    test('isFull and canAdd reflect the 6-member cap', () {
      final empty = PokemonTeam(
        id: 'team-1',
        name: 'Empty',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      expect(empty.isFull, isFalse);
      expect(empty.canAdd, isTrue);

      final full = empty.copyWith(
        members: [
          for (var i = 1; i <= kTeamMaxMembers; i++)
            TeamMember(
              pokemon: PokemonSummary(id: i, name: 'pokemon-$i', spriteUrl: ''),
              addedAt: DateTime.utc(2026, 1, 1),
            ),
        ],
      );
      expect(full.isFull, isTrue);
      expect(full.canAdd, isFalse);
    });
  });
}
