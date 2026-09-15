import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_move_detail_usecase.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';

@injectable
class MoveDetailCubit extends Cubit<MoveDetailState> {
  MoveDetailCubit(this._getMoveDetailUseCase, this._logger)
    : super(MoveDetailInitial());

  final GetMoveDetailUseCase _getMoveDetailUseCase;
  final EnLogger _logger;
  CancellationToken? _cancelToken;

  @override
  Future<void> close() {
    _cancelToken?.cancel('MoveDetailCubit closed');
    return super.close();
  }

  Future<void> fetchMoveDetail(String moveName) async {
    if (moveName.isEmpty) return;

    _cancelToken?.cancel('Superseded by new fetchMoveDetail');
    final token = CancellationToken();
    _cancelToken = token;

    emit(MoveDetailLoading());
    _logger.info('Fetching move detail for $moveName');

    final result = await _getMoveDetailUseCase(moveName, cancelToken: token);

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        _logger.error('Failed to fetch move detail: ${failure.message}');
        emit(MoveDetailError(failure.message, failure: failure));
      },
      (moveDetail) {
        emit(MoveDetailLoaded(moveDetail));
      },
    );
  }
}
