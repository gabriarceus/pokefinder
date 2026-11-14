import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../helpers/in_memory_hydrated_storage.dart';

class _MockEnLogger extends Mock implements EnLogger {}

PokemonSummary _summary(int id, String name) =>
    PokemonSummary(id: id, name: name, spriteUrl: '');

void main() {
  late _MockEnLogger logger;
  late InMemoryHydratedStorage storage;

  setUp(() {
    logger = _MockEnLogger();
    storage = InMemoryHydratedStorage();
    HydratedBloc.storage = storage;
  });

  RecentHistoryCubit buildCubit({Clock? clock}) {
    return RecentHistoryCubit(logger, clock: clock ?? const Clock());
  }

  group('RecentHistoryCubit', () {
    test('addRecentPokemon inserts at top and deduplicates on revisit', () {
      final t1 = DateTime.utc(2026, 1, 1);
      final t2 = DateTime.utc(2026, 1, 2);

      var currentTime = t1;
      final cubit = buildCubit(clock: Clock(() => currentTime));

      cubit.addRecentPokemon(_summary(1, 'bulbasaur'));
      expect(cubit.state.recentPokemon.length, equals(1));
      expect(cubit.state.recentPokemon.first.pokemon.id, equals(1));
      expect(cubit.state.recentPokemon.first.viewedAt, equals(t1));

      cubit.addRecentPokemon(_summary(4, 'charmander'));
      expect(cubit.state.recentPokemon.length, equals(2));
      expect(cubit.state.recentPokemon.first.pokemon.id, equals(4));

      // Revisit Bulbasaur at t2 -> moves to top with updated timestamp
      currentTime = t2;
      cubit.addRecentPokemon(_summary(1, 'bulbasaur'));
      expect(cubit.state.recentPokemon.length, equals(2));
      expect(cubit.state.recentPokemon.first.pokemon.id, equals(1));
      expect(cubit.state.recentPokemon.first.viewedAt, equals(t2));
      expect(cubit.state.recentPokemon[1].pokemon.id, equals(4));
    });

    test('addRecentPokemon enforces maximum capacity of 20 items', () {
      final cubit = buildCubit();

      for (var i = 1; i <= 25; i++) {
        cubit.addRecentPokemon(_summary(i, 'pokemon_$i'));
      }

      expect(cubit.state.recentPokemon.length, equals(kMaxRecentPokemon));
      // Latest item is #25, oldest remaining is #6
      expect(cubit.state.recentPokemon.first.pokemon.id, equals(25));
      expect(cubit.state.recentPokemon.last.pokemon.id, equals(6));
    });

    test(
      'addRecentSearch inserts, deduplicates case-insensitively, and enforces limit',
      () {
        final cubit = buildCubit();

        cubit.addRecentSearch('pikachu');
        cubit.addRecentSearch('charizard');
        expect(cubit.state.recentSearches, equals(['charizard', 'pikachu']));

        // Re-search pikachu with different case -> moved to front
        cubit.addRecentSearch('Pikachu');
        expect(cubit.state.recentSearches, equals(['Pikachu', 'charizard']));

        // Ignore empty queries
        cubit.addRecentSearch('   ');
        expect(cubit.state.recentSearches.length, equals(2));

        // Test capacity (10)
        for (var i = 1; i <= 15; i++) {
          cubit.addRecentSearch('query_$i');
        }
        expect(cubit.state.recentSearches.length, equals(kMaxRecentSearches));
        expect(cubit.state.recentSearches.first, equals('query_15'));
      },
    );

    test('does not record recent items or searches when history is paused', () {
      final cubit = buildCubit();
      cubit.setHistoryEnabled(false);

      cubit.addRecentPokemon(_summary(25, 'pikachu'));
      cubit.addRecentSearch('pikachu');

      expect(cubit.state.recentPokemon, isEmpty);
      expect(cubit.state.recentSearches, isEmpty);
    });

    test('removes individual items and queries', () {
      final cubit = buildCubit();
      cubit.addRecentPokemon(_summary(1, 'bulbasaur'));
      cubit.addRecentPokemon(_summary(4, 'charmander'));
      cubit.addRecentSearch('bulbasaur');
      cubit.addRecentSearch('charmander');

      cubit.removeRecentPokemon(1);
      expect(cubit.state.recentPokemon.map((r) => r.pokemon.id), equals([4]));

      cubit.removeRecentSearch('charmander');
      expect(cubit.state.recentSearches, equals(['bulbasaur']));
    });

    test('clear methods reset respective or all history', () {
      final cubit = buildCubit();
      cubit.addRecentPokemon(_summary(1, 'bulbasaur'));
      cubit.addRecentSearch('bulbasaur');

      cubit.clearRecentPokemon();
      expect(cubit.state.recentPokemon, isEmpty);
      expect(cubit.state.recentSearches, isNotEmpty);

      cubit.clearRecentSearches();
      expect(cubit.state.recentSearches, isEmpty);

      cubit.addRecentPokemon(_summary(1, 'bulbasaur'));
      cubit.addRecentSearch('bulbasaur');
      cubit.clearAllHistory();
      expect(cubit.state.recentPokemon, isEmpty);
      expect(cubit.state.recentSearches, isEmpty);
    });

    test('persists history across cubit restarts', () async {
      final cubit1 = buildCubit();
      cubit1.addRecentPokemon(_summary(25, 'pikachu'));
      cubit1.addRecentSearch('pikachu');
      cubit1.setHistoryEnabled(false);

      await cubit1.close();

      final cubit2 = buildCubit();
      expect(cubit2.state.recentPokemon.length, equals(1));
      expect(cubit2.state.recentPokemon.first.pokemon.name, equals('pikachu'));
      expect(cubit2.state.recentSearches, equals(['pikachu']));
      expect(cubit2.state.isHistoryEnabled, isFalse);
    });

    test('evicts one corrupt record and keeps the rest', () {
      final cubit = buildCubit();

      final state = cubit.fromJson({
        'recentPokemon': [
          {
            'id': 25,
            'name': 'pikachu',
            'spriteUrl': '',
            'types': ['electric'],
            'viewedAt': '2026-01-01T00:00:00.000Z',
          },
          {'name': 'no-id', 'viewedAt': '2026-01-01T00:00:00.000Z'},
          'not even a map',
        ],
        'recentSearches': ['pikachu'],
      });

      expect(state.recentPokemon.map((r) => r.pokemon.name), ['pikachu']);
      expect(state.recentSearches, ['pikachu']);
    });
  });
}
