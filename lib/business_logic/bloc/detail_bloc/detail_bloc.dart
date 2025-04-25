import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/models/pokemon.dart';
import 'package:pokefinder/services/i_pokemon_service.dart';
import 'package:dartz/dartz.dart';

part 'detail_event.dart';
part 'detail_state.dart';

//Here we use the bloc pattern to manage the state of the application
class PokemonBloc extends Bloc<PokemonBlocEvent, PokemonBlocState> {
  final IPokemonService _pokemonService;

  PokemonBloc(this._pokemonService) : super(PokemonBlocInitial()) {
    on<FetchPokemonEvent>(onFetchPokemon);
  }

  FutureOr<void> onFetchPokemon(
      FetchPokemonEvent event, Emitter<PokemonBlocState> emit) async {
    final name = PokemonName(event.pokemonName);
    if (!name.isValid()) {
      return;
    }
    emit(PokemonBlocLoading());
    final Either<Failure, Pokemon> result = await _pokemonService.getData(name);

    // Fold is a method of the dartz library that allows you to handle the two cases of success and failure
    // in a functional way. It takes two functions as arguments, one for the success case and one for the failure case.
    result.fold(
      (failure) => emit(PokemonBlocFailure(failure.message)),
      (pokemon) => emit(PokemonBlocSuccess(pokemon)),
    );
  }
}
