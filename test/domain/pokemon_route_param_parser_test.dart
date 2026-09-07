import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_route_param_parser.dart';

void main() {
  group('parsePokemonRouteParam', () {
    group('valid Pokémon names', () {
      test('normalizes valid lowercase name', () {
        expect(parsePokemonRouteParam('pikachu'), 'pikachu');
      });

      test('trims and lowercases mixed case input', () {
        expect(parsePokemonRouteParam('  Pikachu  '), 'pikachu');
      });

      test('supports hyphenated Pokémon names', () {
        expect(parsePokemonRouteParam('ho-oh'), 'ho-oh');
        expect(parsePokemonRouteParam('tapu-koko'), 'tapu-koko');
        expect(parsePokemonRouteParam('porygon-z'), 'porygon-z');
      });

      test('supports names with digits', () {
        expect(parsePokemonRouteParam('porygon2'), 'porygon2');
      });
    });

    group('valid numeric Pokédex IDs', () {
      test('accepts positive integer strings', () {
        expect(parsePokemonRouteParam('25'), '25');
        expect(parsePokemonRouteParam('1'), '1');
        expect(parsePokemonRouteParam('1025'), '1025');
      });

      test('trims whitespace around numeric IDs', () {
        expect(parsePokemonRouteParam('  25  '), '25');
      });

      test('canonicalizes numeric IDs with leading zeroes', () {
        expect(parsePokemonRouteParam('025'), '25');
        expect(parsePokemonRouteParam('001'), '1');
        expect(parsePokemonRouteParam('0001025'), '1025');
      });
    });

    group('zero and negative IDs', () {
      test('rejects zero', () {
        expect(parsePokemonRouteParam('0'), isNull);
        expect(parsePokemonRouteParam('00'), isNull);
      });

      test('rejects negative numbers', () {
        expect(parsePokemonRouteParam('-1'), isNull);
        expect(parsePokemonRouteParam('-25'), isNull);
      });
    });

    group('invalid or malformed input strings', () {
      test('rejects null, empty, or whitespace strings', () {
        expect(parsePokemonRouteParam(null), isNull);
        expect(parsePokemonRouteParam(''), isNull);
        expect(parsePokemonRouteParam('   '), isNull);
      });

      test('rejects special characters', () {
        expect(parsePokemonRouteParam('invalid!param'), isNull);
        expect(parsePokemonRouteParam('pikachu@home'), isNull);
        expect(parsePokemonRouteParam('pokemon#1'), isNull);
      });

      test('rejects embedded spaces', () {
        expect(parsePokemonRouteParam('pika chu'), isNull);
      });

      test('rejects leading or trailing hyphens', () {
        expect(parsePokemonRouteParam('-pikachu'), isNull);
        expect(parsePokemonRouteParam('pikachu-'), isNull);
      });

      test('rejects consecutive hyphens', () {
        expect(parsePokemonRouteParam('pika--chu'), isNull);
      });

      test('rejects path traversal and script characters', () {
        expect(parsePokemonRouteParam('../../etc/passwd'), isNull);
        expect(parsePokemonRouteParam('<script>'), isNull);
      });
    });
  });
}
