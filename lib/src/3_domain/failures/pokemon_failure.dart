import 'package:equatable/equatable.dart';

sealed class PokemonFailure extends Equatable {
  const PokemonFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class UnauthorizedFailure extends PokemonFailure {
  const UnauthorizedFailure([super.message = 'Unauthorized']);
}

final class BadRequestFailure extends PokemonFailure {
  const BadRequestFailure([super.message = 'Bad Request']);
}

final class PokemonNotFoundFailure extends PokemonFailure {
  const PokemonNotFoundFailure([super.message = 'Pokemon not found']);
}

final class NetworkUnavailableFailure extends PokemonFailure {
  const NetworkUnavailableFailure([super.message = 'Network unavailable']);
}

final class RequestTimeoutFailure extends PokemonFailure {
  const RequestTimeoutFailure([super.message = 'Request timed out']);
}

final class RateLimitedFailure extends PokemonFailure {
  const RateLimitedFailure([super.message = 'Rate limit exceeded']);
}

final class ServerFailure extends PokemonFailure {
  const ServerFailure([this.statusCode, super.message = 'Server error']);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, message];
}

final class InvalidResponseFailure extends PokemonFailure {
  const InvalidResponseFailure([super.message = 'Invalid response']);
}

final class StorageFailure extends PokemonFailure {
  const StorageFailure([super.message = 'Storage failure']);
}

final class UnexpectedFailure extends PokemonFailure {
  const UnexpectedFailure(super.message);
}
