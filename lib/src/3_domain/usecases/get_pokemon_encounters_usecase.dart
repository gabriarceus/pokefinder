import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

import 'package:pokefinder/src/3_domain/cancellation_token.dart';

@lazySingleton
class GetPokemonEncountersUseCase {
  GetPokemonEncountersUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, List<PokemonEncounter>>> call(
    String url, {
    CancellationToken? cancelToken,
  }) {
    return _repository.getEncounters(url, cancelToken: cancelToken);
  }
}
