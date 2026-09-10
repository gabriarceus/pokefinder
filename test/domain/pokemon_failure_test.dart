import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

void main() {
  group('PokemonFailure equality', () {
    test('same subtype compares equal by value', () {
      expect(BadRequestFailure(), BadRequestFailure());
      expect(UnauthorizedFailure(), UnauthorizedFailure());
      expect(PokemonNotFoundFailure(), PokemonNotFoundFailure());
      expect(NetworkUnavailableFailure(), NetworkUnavailableFailure());
      expect(RequestTimeoutFailure(), RequestTimeoutFailure());
      expect(RateLimitedFailure(), RateLimitedFailure());
      expect(const ServerFailure(500), const ServerFailure(500));
      expect(const InvalidResponseFailure(), const InvalidResponseFailure());
      expect(const StorageFailure(), const StorageFailure());
      expect(const UnexpectedFailure('boom'), const UnexpectedFailure('boom'));
    });

    test('different subtypes are not equal', () {
      expect(BadRequestFailure(), isNot(UnauthorizedFailure()));
      expect(PokemonNotFoundFailure(), isNot(NetworkUnavailableFailure()));
      expect(RequestTimeoutFailure(), isNot(RateLimitedFailure()));
      expect(const ServerFailure(500), isNot(const ServerFailure(502)));
      expect(const StorageFailure(), isNot(const InvalidResponseFailure()));
    });

    test('UnexpectedFailure differs by message', () {
      expect(const UnexpectedFailure('a'), isNot(const UnexpectedFailure('b')));
    });

    test('ServerFailure props include statusCode and message', () {
      const failure = ServerFailure(503, 'Gateway Timeout');
      expect(failure.statusCode, 503);
      expect(failure.message, 'Gateway Timeout');
      expect(failure.props, [503, 'Gateway Timeout']);
    });
  });
}
