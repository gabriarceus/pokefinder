import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

@lazySingleton
class GetEvolutionChainUseCase {
  GetEvolutionChainUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, EvolutionChain>> call(
    String url, {
    CancellationToken? cancelToken,
  }) {
    return _repository.getEvolutionChain(url, cancelToken: cancelToken);
  }
}
