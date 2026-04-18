import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_usecase.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

part 'detail_event.dart';
part 'detail_state.dart';

const _prefix = 'DetailBloc';

//Here we use the bloc pattern to manage the state of the application
@injectable
class PokemonBloc extends Bloc<PokemonBlocEvent, PokemonBlocState> {
  final GetPokemonUseCase _getPokemonUseCase;
  final EnLogger _logger;

  PokemonBloc(this._getPokemonUseCase, this._logger)
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
    final Either<PokemonFailure, Pokemon> result =
        await _getPokemonUseCase(name);

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
