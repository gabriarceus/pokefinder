import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';

TeamMember _member(
  String name, {
  int id = 25,
  List<PokemonType> types = const [PokemonType.electric],
}) {
  return TeamMember(
    pokemon: PokemonSummary(id: id, name: name, spriteUrl: '', types: types),
    addedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('TeamSummaryHelper duplicates', () {
    test('exact slugs collide case-insensitively', () {
      final members = [_member('pikachu')];

      expect(TeamSummaryHelper.isDuplicateName(members, 'Pikachu'), isTrue);
      expect(TeamSummaryHelper.isDuplicateName(members, 'raichu'), isFalse);
    });

    test('forms with distinct slugs are distinct members', () {
      final members = [_member('charizard', id: 6)];

      expect(
        TeamSummaryHelper.isDuplicateName(members, 'charizard-mega-x'),
        isFalse,
      );
      expect(
        TeamSummaryHelper.hasDuplicateMembers([
          _member('charizard', id: 6),
          _member('charizard-mega-x', id: 6),
        ]),
        isFalse,
      );
    });

    test('hasDuplicateMembers flags repeats', () {
      final members = [
        _member('pikachu'),
        _member('bulbasaur', id: 1),
        _member('Pikachu'),
      ];

      expect(TeamSummaryHelper.hasDuplicateMembers(members), isTrue);
      expect(
        TeamSummaryHelper.hasDuplicateMembers([
          _member('pikachu'),
          _member('bulbasaur', id: 1),
        ]),
        isFalse,
      );
    });
  });

  group('TeamSummaryHelper type coverage', () {
    test('unions member types in first-seen order without repeats', () {
      final members = [
        _member(
          'bulbasaur',
          id: 1,
          types: const [PokemonType.grass, PokemonType.poison],
        ),
        _member(
          'oddish',
          id: 43,
          types: const [PokemonType.grass, PokemonType.poison],
        ),
        _member('charmander', id: 4, types: const [PokemonType.fire]),
      ];

      expect(
        TeamSummaryHelper.typeCoverage(members),
        equals([PokemonType.grass, PokemonType.poison, PokemonType.fire]),
      );
    });

    test('coverage of fetched pokemons unions both type slots', () {
      final pokemons = [
        buildPokemon(
          id: 1,
          name: 'bulbasaur',
          type1: PokemonType.grass,
          type2: PokemonType.poison,
        ),
        buildPokemon(
          id: 4,
          name: 'charmander',
          type1: PokemonType.fire,
          type2: null,
        ),
      ];

      expect(
        TeamSummaryHelper.typeCoverageOfPokemons(pokemons),
        equals([PokemonType.grass, PokemonType.poison, PokemonType.fire]),
      );
    });
  });

  group('TeamSummaryHelper stat summary', () {
    test('sums and averages base stats across members', () {
      final summary = TeamSummaryHelper.buildStatSummary([
        buildPokemon(stats: const [45, 49, 49, 65, 65, 45]),
        buildPokemon(
          id: 150,
          name: 'mewtwo',
          stats: const [100, 100, 100, 100, 100, 100],
        ),
      ]);

      expect(summary.countedMembers, equals(2));
      expect(summary.sums, equals([145, 149, 149, 165, 165, 145]));
      expect(summary.averages, equals([72.5, 74.5, 74.5, 82.5, 82.5, 72.5]));
      expect(summary.totalSum, equals(918));
      expect(summary.totalAverage, equals(459));
      expect(summary.isEmpty, isFalse);
    });

    test('skips members without usable stats', () {
      final summary = TeamSummaryHelper.buildStatSummary([
        buildPokemon(stats: const [45, 49, 49, 65, 65, 45]),
        buildPokemon(id: 999, name: 'missingno', stats: const [10, 10]),
      ]);

      expect(summary.countedMembers, equals(1));
      expect(summary.sums, equals([45, 49, 49, 65, 65, 45]));
      expect(summary.totalSum, equals(318));
    });

    test('empty input yields an empty summary', () {
      const summary = TeamStatSummary.empty();

      expect(summary.isEmpty, isTrue);
      expect(summary.totalSum, equals(0));
      expect(TeamSummaryHelper.buildStatSummary(const []).isEmpty, isTrue);
    });
  });
}
