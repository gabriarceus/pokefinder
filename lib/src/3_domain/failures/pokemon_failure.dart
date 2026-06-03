import 'package:equatable/equatable.dart';

sealed class PokemonFailure extends Equatable {
  const PokemonFailure(this.message);

  final String message;

  T map<T>({
    required T Function(UnauthorizedFailure failure) onFailure,
    required T Function(BadRequestFailure failure) onBadRequest,
    required T Function(UnexpectedFailure failure) onUnexpected,
  }) {
    switch (this) {
      case UnauthorizedFailure unauthorizedFailure:
        return onFailure(unauthorizedFailure);
      case BadRequestFailure badRequest:
        return onBadRequest(badRequest);
      case UnexpectedFailure unexpected:
        return onUnexpected(unexpected);
    }
  }

  @override
  List<Object?> get props => [message];
}

final class UnauthorizedFailure extends PokemonFailure {
  const UnauthorizedFailure() : super('Unauthorized');
}

final class BadRequestFailure extends PokemonFailure {
  const BadRequestFailure() : super('Bad Request');
}

final class UnexpectedFailure extends PokemonFailure {
  const UnexpectedFailure(super.message);
}
