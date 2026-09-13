import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

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
          id: 25,
          name: 'pikachu',
          spriteUrl: 'https://example.com/25.png',
          types: const [PokemonType.electric],
        );

        expect(cubit.isFavorite(25), isTrue);
        expect(cubit.state.favorites.length, equals(1));
        expect(cubit.state.favorites.first.name, equals('pikachu'));

        cubit.toggleFavorite(
          id: 25,
          name: 'pikachu',
          spriteUrl: 'https://example.com/25.png',
        );

        expect(cubit.isFavorite(25), isFalse);
        expect(cubit.state.favorites, isEmpty);
      },
    );

    test('removeFavorite removes existing favorite by id', () {
      final cubit = buildCubit();
      cubit.addFavorite(id: 1, name: 'bulbasaur', spriteUrl: '');
      cubit.addFavorite(id: 4, name: 'charmander', spriteUrl: '');

      expect(cubit.state.favorites.length, equals(2));

      cubit.removeFavorite(1);

      expect(cubit.state.favorites.length, equals(1));
      expect(cubit.isFavorite(1), isFalse);
      expect(cubit.isFavorite(4), isTrue);
    });

    test('clearFavorites removes all entries', () {
      final cubit = buildCubit();
      cubit.addFavorite(id: 1, name: 'bulbasaur', spriteUrl: '');
      cubit.addFavorite(id: 4, name: 'charmander', spriteUrl: '');

      cubit.clearFavorites();

      expect(cubit.state.favorites, isEmpty);
    });

    group('sorting strategies in sortedFavorites', () {
      late FavoritesCubit cubit;

      setUp(() {
        final t1 = DateTime.utc(2026, 1, 1);
        final t2 = DateTime.utc(2026, 1, 2);
        final t3 = DateTime.utc(2026, 1, 3);

        cubit = buildCubit(clock: Clock(() => t1));
        cubit.addFavorite(id: 25, name: 'Pikachu', spriteUrl: '');

        cubit = FavoritesCubit(logger, clock: Clock(() => t2));
        cubit.emit(
          cubit.state.copyWith(
            favorites: [
              FavoritePokemon(
                id: 25,
                name: 'Pikachu',
                spriteUrl: '',
                addedAt: t1,
              ),
              FavoritePokemon(
                id: 1,
                name: 'Bulbasaur',
                spriteUrl: '',
                addedAt: t2,
              ),
              FavoritePokemon(
                id: 150,
                name: 'Mewtwo',
                spriteUrl: '',
                addedAt: t3,
              ),
            ],
          ),
        );
      });

      test('sorts by idAscending', () {
        cubit.setSortOrder(FavoriteSortOrder.idAscending);
        final ids = cubit.state.sortedFavorites.map((f) => f.id).toList();
        expect(ids, equals([1, 25, 150]));
      });

      test('sorts by idDescending', () {
        cubit.setSortOrder(FavoriteSortOrder.idDescending);
        final ids = cubit.state.sortedFavorites.map((f) => f.id).toList();
        expect(ids, equals([150, 25, 1]));
      });

      test('sorts by nameAscending', () {
        cubit.setSortOrder(FavoriteSortOrder.nameAscending);
        final names = cubit.state.sortedFavorites.map((f) => f.name).toList();
        expect(names, equals(['Bulbasaur', 'Mewtwo', 'Pikachu']));
      });

      test('sorts by nameDescending', () {
        cubit.setSortOrder(FavoriteSortOrder.nameDescending);
        final names = cubit.state.sortedFavorites.map((f) => f.name).toList();
        expect(names, equals(['Pikachu', 'Mewtwo', 'Bulbasaur']));
      });

      test('sorts by recentlyAdded', () {
        cubit.setSortOrder(FavoriteSortOrder.recentlyAdded);
        final ids = cubit.state.sortedFavorites.map((f) => f.id).toList();
        expect(ids, equals([150, 1, 25]));
      });
    });

    test('persists state across cubit restarts', () async {
      final cubit1 = buildCubit();
      cubit1.addFavorite(
        id: 7,
        name: 'squirtle',
        spriteUrl: 'https://example.com/7.png',
        types: const [PokemonType.water],
      );
      cubit1.setSortOrder(FavoriteSortOrder.nameAscending);

      await cubit1.close();

      final cubit2 = buildCubit();
      expect(cubit2.state.favorites.length, equals(1));
      expect(cubit2.state.favorites.first.name, equals('squirtle'));
      expect(cubit2.state.sortOrder, equals(FavoriteSortOrder.nameAscending));
      expect(cubit2.isFavorite(7), isTrue);
    });
  });
}
