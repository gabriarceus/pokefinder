import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

/// Validates and normalizes a raw name.
///
/// On success returns the canonical value: trimmed and lower-cased, so that
/// equivalent inputs (different casing or surrounding whitespace) collapse to
/// a single value used downstream as both the request path and the cache key.
/// Returns a [BadRequestFailure] when the input is empty after trimming.
Either<PokemonFailure, String> _validatePokemonName(String input) {
  final normalized = input.trim().toLowerCase();
  if (normalized.isEmpty) {
    return left(BadRequestFailure());
  }
  return right(normalized);
}

class PokemonName {
  PokemonName(String input) : value = _validatePokemonName(input);

  final Either<PokemonFailure, String> value;

  /// Returns the validated name, or throws the typed [PokemonFailure] on invalid input.
  String rightOrCrash() {
    return value.fold((l) => throw l, id);
  }

  bool isValid() {
    return value.isRight();
  }
}
