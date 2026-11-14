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
}
