import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

@lazySingleton
class GetAbilityDetailUseCase {
  GetAbilityDetailUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, AbilityDetail>> call(
    String name, {
    CancellationToken? cancelToken,
  }) {
    return _repository.getAbilityDetail(name, cancelToken: cancelToken);
  }
}
