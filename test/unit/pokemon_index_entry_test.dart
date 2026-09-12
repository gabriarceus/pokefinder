import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  group('PokemonIndexEntry', () {
    test('creates entry with correct properties and derived URLs', () {
      const entry = PokemonIndexEntry(
        id: 25,
        name: 'pikachu',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
        types: [PokemonType.electric],
      );

      expect(entry.id, 25);
      expect(entry.name, 'pikachu');
      expect(entry.detailUrl, 'https://pokeapi.co/api/v2/pokemon/25/');
      expect(entry.types, [PokemonType.electric]);
      expect(entry.formattedId, '#025');
      expect(
        entry.spriteUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
      );
      expect(
        entry.officialArtworkUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
      );
    });

    test('respects customSpriteUrl when provided', () {
      const entry = PokemonIndexEntry(
        id: 1,
        name: 'bulbasaur',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
        customSpriteUrl: 'https://custom.sprite/1.png',
      );

      expect(entry.spriteUrl, 'https://custom.sprite/1.png');
    });

    test('correctly maps generation from Pokédex numeric ID ranges', () {
      expect(
        const PokemonIndexEntry(
          id: 1,
          name: 'bulbasaur',
          detailUrl: '',
        ).generation,
        1,
      );
      expect(
        const PokemonIndexEntry(id: 151, name: 'mew', detailUrl: '').generation,
        1,
      );
      expect(
        const PokemonIndexEntry(
          id: 152,
          name: 'chikorita',
          detailUrl: '',
        ).generation,
        2,
      );
      expect(
        const PokemonIndexEntry(
          id: 251,
          name: 'celebi',
          detailUrl: '',
        ).generation,
        2,
      );
      expect(
        const PokemonIndexEntry(
          id: 252,
          name: 'treecko',
          detailUrl: '',
        ).generation,
        3,
      );
      expect(
        const PokemonIndexEntry(
          id: 386,
          name: 'deoxys',
          detailUrl: '',
        ).generation,
        3,
      );
      expect(
        const PokemonIndexEntry(
          id: 387,
          name: 'turtwig',
          detailUrl: '',
        ).generation,
        4,
      );
      expect(
        const PokemonIndexEntry(
          id: 493,
          name: 'arceus',
          detailUrl: '',
        ).generation,
        4,
      );
      expect(
        const PokemonIndexEntry(
          id: 494,
          name: 'victini',
          detailUrl: '',
        ).generation,
        5,
      );
      expect(
        const PokemonIndexEntry(
          id: 649,
          name: 'genesect',
          detailUrl: '',
        ).generation,
        5,
      );
      expect(
        const PokemonIndexEntry(
          id: 650,
          name: 'chespin',
          detailUrl: '',
        ).generation,
        6,
      );
      expect(
        const PokemonIndexEntry(
          id: 721,
          name: 'volcanion',
          detailUrl: '',
        ).generation,
        6,
      );
      expect(
        const PokemonIndexEntry(
          id: 722,
          name: 'rowlet',
          detailUrl: '',
        ).generation,
        7,
      );
      expect(
        const PokemonIndexEntry(
          id: 809,
          name: 'melmetal',
          detailUrl: '',
        ).generation,
        7,
      );
      expect(
        const PokemonIndexEntry(
          id: 810,
          name: 'grookey',
          detailUrl: '',
        ).generation,
        8,
      );
      expect(
        const PokemonIndexEntry(
          id: 905,
          name: 'enamorus',
          detailUrl: '',
        ).generation,
        8,
      );
      expect(
        const PokemonIndexEntry(
          id: 906,
          name: 'sprigatito',
          detailUrl: '',
        ).generation,
        9,
      );
      expect(
        const PokemonIndexEntry(
          id: 1025,
          name: 'pecharunt',
          detailUrl: '',
        ).generation,
        9,
      );
      expect(
        const PokemonIndexEntry(
          id: 10001,
          name: 'deoxys-attack',
          detailUrl: '',
        ).generation,
        0,
      );
    });

    test('copyWith updates properties and preserves unchanged fields', () {
      const entry = PokemonIndexEntry(
        id: 4,
        name: 'charmander',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/4/',
      );

      final updated = entry.copyWith(
        types: [PokemonType.fire],
        customSpriteUrl: 'https://test/4.png',
      );

      expect(updated.id, 4);
      expect(updated.name, 'charmander');
      expect(updated.types, [PokemonType.fire]);
      expect(updated.spriteUrl, 'https://test/4.png');
    });

    test('value equality and props', () {
      const entry1 = PokemonIndexEntry(
        id: 7,
        name: 'squirtle',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
      );
      const entry2 = PokemonIndexEntry(
        id: 7,
        name: 'squirtle',
        detailUrl: 'https://pokeapi.co/api/v2/pokemon/7/',
      );

      expect(entry1, equals(entry2));
    });
  });
}
