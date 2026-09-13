import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_evolution_chain_usecase.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_state.dart';

@injectable
class EvolutionCubit extends Cubit<EvolutionState> {
  EvolutionCubit(this._getEvolutionChainUseCase, this._logger)
    : super(const EvolutionInitial());

  final GetEvolutionChainUseCase _getEvolutionChainUseCase;
  final EnLogger _logger;
  CancellationToken? _cancelToken;

  @override
  Future<void> close() {
    _cancelToken?.cancel('EvolutionCubit closed');
    return super.close();
  }

  Future<void> fetchEvolutionChain(String url) async {
    if (url.isEmpty) return;

    _cancelToken?.cancel('Superseded by new fetchEvolutionChain');
    final token = CancellationToken();
    _cancelToken = token;

    emit(const EvolutionLoading());
    _logger.info('Fetching evolution chain from $url');

    final result = await _getEvolutionChainUseCase(url, cancelToken: token);

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        _logger.error('Failed to fetch evolution chain: ${failure.message}');
        emit(EvolutionError(failure.message, failure: failure));
      },
      (chain) {
        emit(EvolutionLoaded(chain));
      },
    );
  }
}
