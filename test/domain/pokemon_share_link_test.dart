import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_share_link.dart';

void main() {
  group('buildPokemonCanonicalPath', () {
    test('builds the canonical path for names', () {
      expect(buildPokemonCanonicalPath('pikachu'), '/pokemon/pikachu');
    });

    test('normalizes names and numeric IDs', () {
      expect(buildPokemonCanonicalPath('  Pikachu  '), '/pokemon/pikachu');
      expect(buildPokemonCanonicalPath('Ho-Oh'), '/pokemon/ho-oh');
      expect(buildPokemonCanonicalPath('025'), '/pokemon/25');
    });

    test('returns null for invalid input', () {
      expect(buildPokemonCanonicalPath(null), isNull);
      expect(buildPokemonCanonicalPath(''), isNull);
      expect(buildPokemonCanonicalPath('   '), isNull);
      expect(buildPokemonCanonicalPath('invalid!param'), isNull);
      expect(buildPokemonCanonicalPath('0'), isNull);
      expect(buildPokemonCanonicalPath('-pikachu'), isNull);
    });
  });

  group('buildPokemonShareUri', () {
    test('builds a deep-link URI on the app scheme', () {
      expect(
        buildPokemonShareUri('pikachu').toString(),
        'pokefinder:///pokemon/pikachu',
      );
      expect(buildPokemonShareUri('25').toString(), 'pokefinder:///pokemon/25');
    });

    test('returns null for invalid input', () {
      expect(buildPokemonShareUri(null), isNull);
      expect(buildPokemonShareUri('invalid!param'), isNull);
      expect(buildPokemonShareUri('0'), isNull);
    });
  });

  group('parsePokemonShareLink', () {
    test('parses canonical paths', () {
      expect(parsePokemonShareLink('/pokemon/pikachu'), 'pikachu');
      expect(parsePokemonShareLink('/pokemon/25'), '25');
    });

    test('parses deep-link URIs', () {
      expect(parsePokemonShareLink('pokefinder:///pokemon/pikachu'), 'pikachu');
      expect(parsePokemonShareLink('pokefinder:///pokemon/25'), '25');
    });

    test('ignores query strings, fragments, and trailing slashes', () {
      expect(parsePokemonShareLink('/pokemon/pikachu?search=pika'), 'pikachu');
      expect(parsePokemonShareLink('/pokemon/25#stats'), '25');
      expect(parsePokemonShareLink('/pokemon/pikachu/'), 'pikachu');
      expect(
        parsePokemonShareLink('https://example.com/pokemon/ho-oh?x=1'),
        'ho-oh',
      );
    });

    test('accepts bare identifiers', () {
      expect(parsePokemonShareLink('pikachu'), 'pikachu');
      expect(parsePokemonShareLink('25'), '25');
    });

    test('returns null for invalid input', () {
      expect(parsePokemonShareLink(null), isNull);
      expect(parsePokemonShareLink(''), isNull);
      expect(parsePokemonShareLink('   '), isNull);
      expect(parsePokemonShareLink('/pokemon/invalid!param'), isNull);
      expect(parsePokemonShareLink('/pokemon/0'), isNull);
      expect(parsePokemonShareLink('/pokemon/'), isNull);
      expect(parsePokemonShareLink('/pokedex'), isNull);
    });

    test('link build/parse round-trips names and numeric IDs', () {
      for (final id in ['pikachu', 'ho-oh', 'tapu-koko', '25', '1025']) {
        final path = buildPokemonCanonicalPath(id);
        expect(path, isNotNull);
        expect(parsePokemonShareLink(path), parsePokemonShareLink(id));
        final uri = buildPokemonShareUri(id);
        expect(uri, isNotNull);
        expect(
          parsePokemonShareLink(uri.toString()),
          parsePokemonShareLink(id),
        );
      }
    });
  });
}
