import 'package:pokefinder/src/3_domain/models/pokemon.dart';
import 'package:dartz/dartz.dart';

Either<Failure, String> _validatePokemonName(String input) {
  return right(input);
}

class PokemonName {
  final Either<Failure, String> value;

  PokemonName(String input) : value = _validatePokemonName(input);

  String rightOrCrash() {
    return value.fold((l) => throw ArgumentError(l.message), id);
  }

  bool isValid() {
    return value.isRight();
  }
}

// Interface for the Pokemon service: this way it doesn't need to know if the data is retrieved from a real API or if it is generated locally (mocked).
abstract class IPokemonService {
  Future<Either<Failure, Pokemon>> getData(PokemonName name);
}

// Used to return an error message in case of failure
sealed class Failure {
  final String message;

  Failure(this.message);

  T map<T>({
    required T Function(UnauthorizedFailure failure) onFailure,
    required T Function(BadRequestFailure failure) onBadRequest,
    required T Function(Failure failure) onOther,
  }) {
    switch (this) {
      case UnauthorizedFailure unauthorizedFailure:
        return onFailure(unauthorizedFailure);
      case BadRequestFailure badRequest:
        return onBadRequest(badRequest);
      default:
        return onOther(this);
    }
  }
}

final class UnauthorizedFailure extends Failure {
  UnauthorizedFailure() : super('Unauthorized');
}

final class BadRequestFailure extends Failure {
  BadRequestFailure() : super('Bad Request');
}
