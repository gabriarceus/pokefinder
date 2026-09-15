import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

@lazySingleton
class GetMoveDetailUseCase {
  GetMoveDetailUseCase(this._repository);

  final IPokemonRepository _repository;

  Future<Either<PokemonFailure, MoveDetail>> call(
    String name, {
    CancellationToken? cancelToken,
  }) {
    return _repository.getMoveDetail(name, cancelToken: cancelToken);
  }
}
