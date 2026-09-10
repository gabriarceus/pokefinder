import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_route_param_parser.dart';

/// Validates and normalizes a raw name or numeric Pokédex ID.
///
/// On success returns the canonical value: trimmed and lower-cased, so that
/// equivalent inputs (different casing, surrounding whitespace, leading zeroes)
/// collapse to a single value used downstream as both the request path and the cache key.
/// Returns a [BadRequestFailure] when the input is empty, non-positive, or malformed.
Either<PokemonFailure, String> _validatePokemonName(String input) {
  final canonical = parsePokemonRouteParam(input);
  if (canonical == null) {
    return left(BadRequestFailure());
  }
  return right(canonical);
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
