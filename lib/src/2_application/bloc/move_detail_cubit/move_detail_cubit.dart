import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';

@injectable
class MoveDetailCubit extends Cubit<MoveDetailState> {
  MoveDetailCubit(this._repository, this._logger) : super(MoveDetailInitial());

  final IPokemonRepository _repository;
  final EnLogger _logger;

  Future<void> fetchMoveDetail(String moveName) async {
    if (moveName.isEmpty) return;

    emit(MoveDetailLoading());
    _logger.info('Fetching move detail for $moveName');

    final result = await _repository.getMoveDetail(moveName);
    if (isClosed) return;

    result.fold((failure) {
      _logger.error('Failed to fetch move detail: ${failure.message}');
      emit(MoveDetailError(failure.message, failure: failure));
    }, (moveDetail) => emit(MoveDetailLoaded(moveDetail)));
  }
}
