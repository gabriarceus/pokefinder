import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

void main() {
  group('PokemonFailure equality', () {
    test('same subtype compares equal by value', () {
      expect(BadRequestFailure(), BadRequestFailure());
      expect(UnauthorizedFailure(), UnauthorizedFailure());
      expect(UnexpectedFailure('boom'), UnexpectedFailure('boom'));
    });

    test('different subtypes are not equal', () {
      expect(BadRequestFailure(), isNot(UnauthorizedFailure()));
    });

    test('UnexpectedFailure differs by message', () {
      expect(UnexpectedFailure('a'), isNot(UnexpectedFailure('b')));
    });
  });
}
