import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_state.dart';

@injectable
class EvolutionCubit extends Cubit<EvolutionState> {
  EvolutionCubit(this._repository, this._logger)
    : super(const EvolutionInitial());

  final IPokemonRepository _repository;
  final EnLogger _logger;

  Future<void> fetchEvolutionChain(String url) async {
    if (url.isEmpty) return;

    emit(const EvolutionLoading());
    _logger.info('Fetching evolution chain from $url');

    final result = await _repository.getEvolutionChain(url);
    if (isClosed) return;

    result.fold((failure) {
      _logger.error('Failed to fetch evolution chain: ${failure.message}');
      emit(EvolutionError(failure.message, failure: failure));
    }, (chain) => emit(EvolutionLoaded(chain)));
  }
}
