class PokemonFailure {
  final String message;

  PokemonFailure(this.message);

  T map<T>({
    required T Function(UnauthorizedFailure failure) onFailure,
    required T Function(BadRequestFailure failure) onBadRequest,
    required T Function(PokemonFailure failure) onOther,
  }) {
    switch (this) {
      case UnauthorizedFailure unauthorizedFailure:
        return onFailure(unauthorizedFailure);
      case BadRequestFailure badRequest:
        return onBadRequest(badRequest);
    }

    return onOther(this);
  }
}

final class UnauthorizedFailure extends PokemonFailure {
  UnauthorizedFailure() : super('Unauthorized');
}

final class BadRequestFailure extends PokemonFailure {
  BadRequestFailure() : super('Bad Request');
}
