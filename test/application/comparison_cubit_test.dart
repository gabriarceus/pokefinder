import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
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
const _squirtle = PokemonIndexEntry(
  id: 7,
  name: 'squirtle',
  detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
  types: [PokemonType.water],
);

void main() {
  late _MockEnLogger logger;

  setUp(() {
    logger = _MockEnLogger();
  });

  ComparisonCubit buildCubit() => ComparisonCubit(logger);

  group('ComparisonCubit', () {
    test('initial state is empty', () {
      final cubit = buildCubit();

      expect(cubit.state.entries, isEmpty);
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.isFull, isFalse);
      expect(cubit.state.canAdd, isTrue);
    });

    test('addEntry stores entries in insertion order', () {
      final cubit = buildCubit();

      expect(cubit.addEntry(_bulbasaur), isTrue);
      expect(cubit.addEntry(_charmander), isTrue);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([1, 4]),
      );
      expect(cubit.state.isFull, isTrue);
      expect(cubit.state.canAdd, isFalse);
    });

    test('addEntry enforces the max-2 cap and keeps existing entries', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);
      cubit.addEntry(_charmander);

      expect(cubit.addEntry(_squirtle), isFalse);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([1, 4]),
      );
      expect(cubit.isSelected(7), isFalse);
    });

    test('addEntry ignores duplicates', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);

      expect(cubit.addEntry(_bulbasaur), isFalse);
      expect(cubit.state.entries.length, equals(1));
    });

    test('removeEntry removes only the matching entry', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);
      cubit.addEntry(_charmander);

      cubit.removeEntry(1);

      expect(
        cubit.state.entries.map((entry) => entry.id).toList(),
        equals([4]),
      );
      expect(cubit.isSelected(1), isFalse);
      expect(cubit.isSelected(4), isTrue);
    });

    test('removeEntry ignores unknown ids', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);

      cubit.removeEntry(999);

      expect(cubit.state.entries.length, equals(1));
    });

    test('toggleEntry adds then removes the same entry', () {
      final cubit = buildCubit();

      expect(cubit.toggleEntry(_bulbasaur), isTrue);
      expect(cubit.isSelected(1), isTrue);

      expect(cubit.toggleEntry(_bulbasaur), isFalse);
      expect(cubit.isSelected(1), isFalse);
      expect(cubit.state.entries, isEmpty);
    });

    test('toggleEntry refuses a third entry while full', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);
      cubit.addEntry(_charmander);

      expect(cubit.toggleEntry(_squirtle), isFalse);
      expect(cubit.state.entries.length, equals(2));
    });

    test('clear removes all entries', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);
      cubit.addEntry(_charmander);

      cubit.clear();

      expect(cubit.state.entries, isEmpty);
      expect(cubit.state.canAdd, isTrue);
    });

    test('entries hold lightweight index refs only', () {
      final cubit = buildCubit();
      cubit.addEntry(_bulbasaur);

      final stored = cubit.state.entries.single;
      expect(stored, isA<PokemonIndexEntry>());
      expect(stored.id, equals(1));
      expect(stored.name, equals('bulbasaur'));
    });
  });
}
