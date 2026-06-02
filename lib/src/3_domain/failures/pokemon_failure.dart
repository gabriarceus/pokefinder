sealed class PokemonFailure {
  PokemonFailure(this.message);

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
}

final class UnauthorizedFailure extends PokemonFailure {
  UnauthorizedFailure() : super('Unauthorized');
}

final class BadRequestFailure extends PokemonFailure {
  BadRequestFailure() : super('Bad Request');
}

final class UnexpectedFailure extends PokemonFailure {
  UnexpectedFailure(super.message);
}
