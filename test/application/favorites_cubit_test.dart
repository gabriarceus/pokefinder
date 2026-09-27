import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

/// A [Clock] whose current time the test moves by hand.
///
/// The injected default is `const Clock()`, which reads the system clock
/// directly, so `withClock` from `package:clock` cannot steer it.
class _MutableClock extends Clock {
  _MutableClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

PokemonSummary _summary(
  int id,
  String name, {
  String spriteUrl = '',
  List<PokemonType> types = const [],
}) => PokemonSummary(id: id, name: name, spriteUrl: spriteUrl, types: types);

void main() {
  late _MockEnLogger logger;
  late InMemoryHydratedStorage storage;

  setUp(() {
    logger = _MockEnLogger();
    storage = InMemoryHydratedStorage();
    HydratedBloc.storage = storage;
  });

  FavoritesCubit buildCubit({Clock? clock}) {
    return FavoritesCubit(logger, clock: clock ?? const Clock());
  }

  group('FavoritesCubit', () {
    test('initial state has empty favorites and idAscending sort order', () {
      final cubit = buildCubit();
      expect(cubit.state.favorites, isEmpty);
      expect(cubit.state.sortOrder, FavoriteSortOrder.idAscending);
    });

    test(
      'toggleFavorite adds item when not favorite, then removes when toggled again',
      () {
        final cubit = buildCubit();

        expect(cubit.isFavorite(25), isFalse);

        cubit.toggleFavorite(
          _summary(
            25,
            'pikachu',
            spriteUrl: 'https://example.com/25.png',
            types: const [PokemonType.electric],
          ),
        );

        expect(cubit.isFavorite(25), isTrue);
        expect(cubit.state.favorites.length, equals(1));
        expect(cubit.state.favorites.first.pokemon.name, equals('pikachu'));

        cubit.toggleFavorite(
          _summary(25, 'pikachu', spriteUrl: 'https://example.com/25.png'),
        );

        expect(cubit.isFavorite(25), isFalse);
        expect(cubit.state.favorites, isEmpty);
      },
    );

    test('toggleFavorite replaces the stored summary for an existing id', () {
      final cubit = buildCubit();
      cubit.addFavorite(_summary(25, 'pikachu', types: const []));

      // A shiny form of the same species is the same favorite, not a duplicate.
      cubit.addFavorite(
        _summary(
          25,
          'pikachu',
          spriteUrl: 'shiny.png',
          types: const [PokemonType.electric],
        ),
      );

      expect(cubit.state.favorites.length, equals(1));
      expect(cubit.state.favorites.first.pokemon.spriteUrl, 'shiny.png');
      expect(cubit.state.favorites.first.pokemon.types, [PokemonType.electric]);
    });

    test('removeFavorite removes existing favorite by id', () {
      final cubit = buildCubit();
      cubit.addFavorite(_summary(1, 'bulbasaur'));
      cubit.addFavorite(_summary(4, 'charmander'));

      expect(cubit.state.favorites.length, equals(2));

      cubit.removeFavorite(1);

      expect(cubit.state.favorites.length, equals(1));
      expect(cubit.isFavorite(1), isFalse);
      expect(cubit.isFavorite(4), isTrue);
    });

    test('clearFavorites removes all entries', () {
      final cubit = buildCubit();
      cubit.addFavorite(_summary(1, 'bulbasaur'));
      cubit.addFavorite(_summary(4, 'charmander'));

      cubit.clearFavorites();

      expect(cubit.state.favorites, isEmpty);
    });

    group('sorting strategies in sortedFavorites', () {
      late FavoritesCubit cubit;
      late _MutableClock clock;

      setUp(() {
        final t1 = DateTime.utc(2026, 1, 1);
        final t2 = DateTime.utc(2026, 1, 2);
        final t3 = DateTime.utc(2026, 1, 3);

        clock = _MutableClock(t1);
        cubit = buildCubit(clock: clock);

        // Added oldest first, so `recentlyAdded` has something to reverse.
        clock.current = t1;
        cubit.addFavorite(_summary(25, 'Pikachu'));
        clock.current = t2;
        cubit.addFavorite(_summary(1, 'Bulbasaur'));
        clock.current = t3;
        cubit.addFavorite(_summary(150, 'Mewtwo'));
      });

      test('sorts by idAscending', () {
        cubit.setSortOrder(FavoriteSortOrder.idAscending);
        final ids = cubit.state.sortedFavorites
            .map((f) => f.pokemon.id)
            .toList();
        expect(ids, equals([1, 25, 150]));
      });

      test('sorts by idDescending', () {
        cubit.setSortOrder(FavoriteSortOrder.idDescending);
        final ids = cubit.state.sortedFavorites
            .map((f) => f.pokemon.id)
            .toList();
        expect(ids, equals([150, 25, 1]));
      });

      test('sorts by nameAscending', () {
        cubit.setSortOrder(FavoriteSortOrder.nameAscending);
        final names = cubit.state.sortedFavorites
            .map((f) => f.pokemon.name)
            .toList();
        expect(names, equals(['Bulbasaur', 'Mewtwo', 'Pikachu']));
      });

      test('sorts by nameDescending', () {
        cubit.setSortOrder(FavoriteSortOrder.nameDescending);
        final names = cubit.state.sortedFavorites
            .map((f) => f.pokemon.name)
            .toList();
        expect(names, equals(['Pikachu', 'Mewtwo', 'Bulbasaur']));
      });

      test('sorts by recentlyAdded', () {
        cubit.setSortOrder(FavoriteSortOrder.recentlyAdded);
        final names = cubit.state.sortedFavorites
            .map((f) => f.pokemon.name)
            .toList();
        expect(names, equals(['Mewtwo', 'Bulbasaur', 'Pikachu']));
      });

      test('does not mutate the stored order', () {
        cubit.setSortOrder(FavoriteSortOrder.recentlyAdded);
        cubit.state.sortedFavorites;

        final stored = cubit.state.favorites.map((f) => f.pokemon.id).toList();
        expect(stored, equals([25, 1, 150]));
      });
    });

    test('persists state across cubit restarts', () async {
      final cubit1 = buildCubit();
      cubit1.addFavorite(
        _summary(
          7,
          'squirtle',
          spriteUrl: 'https://example.com/7.png',
          types: const [PokemonType.water],
        ),
      );
      cubit1.setSortOrder(FavoriteSortOrder.nameAscending);

      await cubit1.close();

      final cubit2 = buildCubit();
      expect(cubit2.state.favorites.length, equals(1));
      expect(cubit2.state.favorites.first.pokemon.name, equals('squirtle'));
      expect(cubit2.state.favorites.first.pokemon.types, [PokemonType.water]);
      expect(cubit2.state.sortOrder, equals(FavoriteSortOrder.nameAscending));
      expect(cubit2.isFavorite(7), isTrue);
    });

    test('evicts one corrupt record and keeps the rest', () async {
      final cubit = buildCubit();

      final state = cubit.fromJson({
        'favorites': [
          {
            'id': 25,
            'name': 'pikachu',
            'spriteUrl': '',
            'types': ['electric'],
            'addedAt': '2026-01-01T00:00:00.000Z',
          },
          {'id': 0, 'name': '', 'addedAt': '2026-01-01T00:00:00.000Z'},
          {'name': 'no-id', 'addedAt': '2026-01-01T00:00:00.000Z'},
        ],
      });

      expect(state.favorites.map((f) => f.pokemon.name), ['pikachu']);
    });
  });
}
