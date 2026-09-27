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

  group('PokemonSummary form identity', () {
    final now = DateTime.utc(2026, 9, 13, 12, 0, 0);

    test('round-trips the form lineage through JSON', () {
      const original = PokemonSummary(
        id: 10034,
        name: 'charizard-mega-x',
        spriteUrl: 'https://example.com/10034.png',
        types: [PokemonType.fire, PokemonType.dragon],
        parentSpeciesId: 6,
        parentSpeciesName: 'charizard',
        formCategory: PokemonFormCategory.mega,
      );

      final restored = PokemonSummary.fromJson(original.toJson());

      expect(restored, equals(original));
    });

    test('loads a record written before the lineage was stored', () {
      final restored = PokemonSummary.fromJson({
        'id': 6,
        'name': 'charizard',
        'spriteUrl': 'https://example.com/6.png',
        'types': ['fire', 'flying'],
      });

      expect(restored.id, 6);
      expect(restored.formCategory, PokemonFormCategory.canonical);
      expect(restored.parentSpeciesId, isNull);
      expect(restored.regionalGroup, isNull);
    });

    test('rebuilds an index entry that keeps the localized display name', () {
      const summary = PokemonSummary(
        id: 10103,
        name: 'vulpix-alola',
        spriteUrl: 'https://example.com/10103.png',
        types: [PokemonType.ice],
        parentSpeciesId: 37,
        parentSpeciesName: 'vulpix',
        formCategory: PokemonFormCategory.regional,
        regionalGroup: PokemonRegionalGroup.alola,
      );

      final entry = summary.toIndexEntry();

      expect(entry.id, 10103);
      expect(entry.effectiveParentSpeciesId, 37);
      expect(entry.getDisplayName(languageCode: 'en'), 'Alolan Vulpix');
      expect(entry.getDisplayName(languageCode: 'it'), 'Vulpix di Alola');
      expect(entry.formBadgeText, 'ALOLA');
      // A round trip must not degrade the artwork back to the pixel sprite.
      expect(entry.displaySpriteUrl, 'https://example.com/10103.png');
    });

    test('distinguishes a form from its base species by id', () {
      final base = const PokemonSummary(
        id: 6,
        name: 'charizard',
        spriteUrl: '',
      );
      final megaX = const PokemonSummary(
        id: 10034,
        name: 'charizard-mega-x',
        spriteUrl: '',
      );

      expect(base, isNot(equals(megaX)));
      expect(
        FavoritePokemon(pokemon: base, addedAt: now),
        isNot(equals(FavoritePokemon(pokemon: megaX, addedAt: now))),
      );
    });
  });
}
