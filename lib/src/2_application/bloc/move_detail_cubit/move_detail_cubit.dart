import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';

@injectable
class MoveDetailCubit extends Cubit<MoveDetailState> {
  MoveDetailCubit(
    this._pokemonRepository,
    this._logger,
  ) : super(MoveDetailInitial());

  final IPokemonRepository _pokemonRepository;
  final EnLogger _logger;

  Future<void> fetchMoveDetail(String moveName) async {
    emit(MoveDetailLoading());
    final result = await _pokemonRepository.getMoveDetail(moveName);
    result.fold(
      (failure) {
        _logger.error('Failed to fetch move detail for $moveName: ${failure.message}');
        emit(MoveDetailError(failure.message));
      },
      (moveDetail) {
        emit(MoveDetailLoaded(moveDetail));
      },
    );
  }
}
