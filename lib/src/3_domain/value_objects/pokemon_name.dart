import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

Either<PokemonFailure, String> _validatePokemonName(String input) {
  if (input.trim().isEmpty) {
    return left(BadRequestFailure());
  }
  return right(input);
}

class PokemonName {
  PokemonName(String input) : value = _validatePokemonName(input);

  final Either<PokemonFailure, String> value;

  String rightOrCrash() {
    return value.fold((l) => throw ArgumentError(l.message), id);
  }

  bool isValid() {
    return value.isRight();
  }
}
