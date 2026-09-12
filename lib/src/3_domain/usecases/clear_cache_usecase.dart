import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

@lazySingleton
class ClearCacheUseCase {
  ClearCacheUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, Unit>> call() {
    return _repository.clearCache();
  }
}
