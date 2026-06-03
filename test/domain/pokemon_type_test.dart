import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

void main() {
  group('PokemonType.fromId', () {
    test('resolves known ids to their type', () {
      expect(PokemonType.fromId(1), PokemonType.normal);
      expect(PokemonType.fromId(10), PokemonType.fire);
      expect(PokemonType.fromId(19), PokemonType.stellar);
    });

    test('returns null for unknown ids', () {
      expect(PokemonType.fromId(0), isNull);
      expect(PokemonType.fromId(9999), isNull);
    });

    test('id and apiName stay in sync for every variant', () {
      for (final type in PokemonType.values) {
        expect(PokemonType.fromId(type.id), type);
        expect(type.apiName, isNotEmpty);
      }
    });
  });
}
