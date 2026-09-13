import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_species.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

@lazySingleton
class GetPokemonSpeciesUseCase {
  GetPokemonSpeciesUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, PokemonSpecies>> call(
    String url, {
    CancellationToken? cancelToken,
  }) {
    return _repository.getPokemonSpecies(url, cancelToken: cancelToken);
  }
}
