import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/pokeapi_url_helper.dart';

void main() {
  group('PokeApiUrlHelper', () {
    test(
      'extractId extracts trailing numeric ID from URL with or without trailing slash',
      () {
        expect(
          PokeApiUrlHelper.extractId('https://pokeapi.co/api/v2/pokemon/25/'),
          25,
        );
        expect(
          PokeApiUrlHelper.extractId(
            'https://pokeapi.co/api/v2/pokemon-form/10034',
          ),
          10034,
        );
        expect(
          PokeApiUrlHelper.extractId('https://pokeapi.co/api/v2/type/10/'),
          10,
        );
      },
    );

    test('extractId returns -1 for unparseable URLs', () {
      expect(PokeApiUrlHelper.extractId(''), -1);
      expect(PokeApiUrlHelper.extractId('not-a-valid-url'), -1);
      expect(
        PokeApiUrlHelper.extractId('https://pokeapi.co/api/v2/pokemon/'),
        -1,
      );
    });

    test('builds official artwork URLs', () {
      expect(
        PokeApiUrlHelper.officialArtworkUrl(6),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/6.png',
      );
      expect(
        PokeApiUrlHelper.officialArtworkUrl(6, shiny: true),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/6.png',
      );
    });

    test('builds sprite and type sprite URLs', () {
      expect(
        PokeApiUrlHelper.spriteUrl(25),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
      );
      expect(
        PokeApiUrlHelper.typeSpriteUrl(10),
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/10.png',
      );
    });
  });
}
