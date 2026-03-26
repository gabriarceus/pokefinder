import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

Either<PokemonFailure, String> _validatePokemonName(String input) {
  return right(input);
}

class PokemonName {
  final Either<PokemonFailure, String> value;

  PokemonName(String input) : value = _validatePokemonName(input);

  String rightOrCrash() {
    return value.fold((l) => throw ArgumentError(l.message), id);
  }

  bool isValid() {
    return value.isRight();
  }
}
