import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('FavoritePokemon entity', () {
    final now = DateTime.utc(2026, 9, 13, 12, 0, 0);

    test('supports value equality', () {
      final fav1 = FavoritePokemon(
        pokemon: const PokemonSummary(
          id: 25,
          name: 'pikachu',
          spriteUrl: 'https://example.com/25.png',
          types: [PokemonType.electric],
        ),
        addedAt: now,
      );
      final fav2 = FavoritePokemon(
        pokemon: const PokemonSummary(
          id: 25,
          name: 'pikachu',
          spriteUrl: 'https://example.com/25.png',
          types: [PokemonType.electric],
        ),
        addedAt: now,
      );
      expect(fav1, equals(fav2));
    });

    test('serializes to JSON and deserializes back faithfully', () {
      final original = FavoritePokemon(
        pokemon: const PokemonSummary(
          id: 1,
          name: 'bulbasaur',
          spriteUrl: 'https://example.com/1.png',
          types: [PokemonType.grass, PokemonType.poison],
        ),
        addedAt: now,
      );

      final json = original.toJson();
      final restored = FavoritePokemon.fromJson(json);

      expect(restored, equals(original));
      expect(restored.pokemon.id, equals(1));
      expect(restored.pokemon.name, equals('bulbasaur'));
      expect(
        restored.pokemon.types,
        equals([PokemonType.grass, PokemonType.poison]),
      );
      expect(restored.addedAt, equals(now));
    });

    test('handles missing or malformed fields gracefully in fromJson', () {
      final restored = FavoritePokemon.fromJson({'id': 7, 'name': 'squirtle'});
      expect(restored.pokemon.id, equals(7));
      expect(restored.pokemon.name, equals('squirtle'));
      expect(restored.pokemon.spriteUrl, isEmpty);
      expect(restored.pokemon.types, isEmpty);
      expect(restored.addedAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });
  });

  group('RecentPokemon entity', () {
    final now = DateTime.utc(2026, 9, 13, 12, 0, 0);

    test('supports value equality', () {
      final rec1 = RecentPokemon(
        pokemon: const PokemonSummary(
          id: 4,
          name: 'charmander',
          spriteUrl: 'https://example.com/4.png',
          types: [PokemonType.fire],
        ),
        viewedAt: now,
      );
      final rec2 = RecentPokemon(
        pokemon: const PokemonSummary(
          id: 4,
          name: 'charmander',
          spriteUrl: 'https://example.com/4.png',
          types: [PokemonType.fire],
        ),
        viewedAt: now,
      );
      expect(rec1, equals(rec2));
    });

    test('serializes to JSON and deserializes back faithfully', () {
      final original = RecentPokemon(
        pokemon: const PokemonSummary(
          id: 4,
          name: 'charmander',
          spriteUrl: 'https://example.com/4.png',
          types: [PokemonType.fire],
        ),
        viewedAt: now,
      );

      final json = original.toJson();
      final restored = RecentPokemon.fromJson(json);

      expect(restored, equals(original));
      expect(restored.pokemon.id, equals(4));
      expect(restored.pokemon.name, equals('charmander'));
      expect(restored.viewedAt, equals(now));
    });
  });
}
