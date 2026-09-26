import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/2_application/bloc/species_cubit/species_state.dart';

@injectable
class SpeciesCubit extends Cubit<SpeciesState> {
  SpeciesCubit(this._repository, this._logger) : super(const SpeciesInitial());

  final IPokemonRepository _repository;
  final EnLogger _logger;

  Future<void> fetchSpecies(String url) async {
    if (url.isEmpty) return;

    emit(const SpeciesLoading());
    _logger.info('Fetching species from $url');

    final result = await _repository.getPokemonSpecies(url);
    if (isClosed) return;

    result.fold((failure) {
      _logger.error('Failed to fetch species: ${failure.message}');
      emit(SpeciesError(failure.message, failure: failure));
    }, (species) => emit(SpeciesLoaded(species)));
  }
}
