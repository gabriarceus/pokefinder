import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:en_logger/en_logger.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/models/pokemon.dart';
import 'package:pokefinder/src/4_repository/services/i_pokemon_service.dart';
import 'package:dartz/dartz.dart';

part 'detail_event.dart';
part 'detail_state.dart';

const _prefix = 'DetailBloc';

//Here we use the bloc pattern to manage the state of the application
class PokemonBloc extends Bloc<PokemonBlocEvent, PokemonBlocState> {
  final IPokemonService _pokemonService;
  final EnLogger _logger;

  PokemonBloc(this._pokemonService, this._logger)
      : super(PokemonBlocInitial()) {
    on<FetchPokemonEvent>(onFetchPokemon);
  }

  FutureOr<void> onFetchPokemon(
      FetchPokemonEvent event, Emitter<PokemonBlocState> emit) async {
    final name = PokemonName(event.pokemonName);
    if (!name.isValid()) {
      return;
    }
    emit(PokemonBlocLoading());
    _logger.info('Fetching data for Pokemon: ${name.rightOrCrash()}',
        prefix: _prefix);
    final Either<Failure, Pokemon> result = await _pokemonService.getData(name);

    // Fold is a method of the dartz library that allows you to handle the two cases of success and failure
    // in a functional way. It takes two functions as arguments, one for the success case and one for the failure case.
    result.fold(
      (failure) {
        _logger.error('Failed to fetch Pokemon: ${failure.message}',
            prefix: _prefix);
        emit(PokemonBlocFailure(failure.message));
      },
      (pokemon) {
        _logger.info('Successfully fetched Pokemon: ${pokemon.name}',
            prefix: _prefix);
        emit(PokemonBlocSuccess(pokemon));
      },
    );
  }
}
