import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_species_usecase.dart';
import 'package:pokefinder/src/2_application/bloc/species_cubit/species_state.dart';

@injectable
class SpeciesCubit extends Cubit<SpeciesState> {
  SpeciesCubit(this._getPokemonSpeciesUseCase, this._logger)
    : super(const SpeciesInitial());

  final GetPokemonSpeciesUseCase _getPokemonSpeciesUseCase;
  final EnLogger _logger;
  CancellationToken? _cancelToken;

  @override
  Future<void> close() {
    _cancelToken?.cancel('SpeciesCubit closed');
    return super.close();
  }

  Future<void> fetchSpecies(String url) async {
    if (url.isEmpty) return;

    _cancelToken?.cancel('Superseded by new fetchSpecies');
    final token = CancellationToken();
    _cancelToken = token;

    emit(const SpeciesLoading());
    _logger.info('Fetching species from $url');

    final result = await _getPokemonSpeciesUseCase(url, cancelToken: token);

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        _logger.error('Failed to fetch species: ${failure.message}');
        emit(SpeciesError(failure.message, failure: failure));
      },
      (species) {
        emit(SpeciesLoaded(species));
      },
    );
  }
}
