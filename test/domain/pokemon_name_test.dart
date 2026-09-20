import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

void main() {
  group('PokemonName', () {
    test('trims and lower-cases a valid input', () {
      final name = PokemonName('  Pikachu  ');

      expect(name.isValid(), isTrue);
      expect(name.rightOrCrash(), 'pikachu');
    });

    test('normalizes differently cased/padded inputs to the same value', () {
      expect(
        PokemonName(' Pikachu ').rightOrCrash(),
        PokemonName('pikachu').rightOrCrash(),
      );
    });

    test('is invalid when input is empty or whitespace only', () {
      expect(PokemonName('').isValid(), isFalse);
      expect(PokemonName('   ').isValid(), isFalse);
    });

    test('rightOrCrash throws the typed PokemonFailure on invalid input', () {
      expect(
        () => PokemonName('').rightOrCrash(),
        throwsA(isA<BadRequestFailure>()),
      );
    });

    test('accepts and canonicalizes positive numeric Pokédex IDs', () {
      expect(PokemonName('25').isValid(), isTrue);
      expect(PokemonName('25').rightOrCrash(), '25');
      expect(PokemonName('  025  ').isValid(), isTrue);
      expect(PokemonName('  025  ').rightOrCrash(), '25');
      expect(PokemonName('1025').rightOrCrash(), '1025');
    });

    test('rejects zero and negative numbers', () {
      expect(PokemonName('0').isValid(), isFalse);
      expect(PokemonName('00').isValid(), isFalse);
      expect(PokemonName('-1').isValid(), isFalse);
      expect(PokemonName('-25').isValid(), isFalse);
    });

    test(
      'rejects path traversal, script injection, and invalid characters',
      () {
        expect(PokemonName('../../etc/passwd').isValid(), isFalse);
        expect(PokemonName('<script>').isValid(), isFalse);
        expect(PokemonName('pika chu').isValid(), isFalse);
        expect(PokemonName('pika@chu').isValid(), isFalse);
        expect(PokemonName('pika--chu').isValid(), isFalse);
      },
    );
  });
}
