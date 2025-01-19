import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/models/pokemon.dart';
import 'package:pokefinder/services/i_pokemon_service.dart';
import 'package:dartz/dartz.dart';

part 'detail_bloc_event.dart';
part 'detail_bloc_state.dart';

//La business logic: si occupa di gestire lo stato dell'applicazione
class PokemonBlocBloc extends Bloc<PokemonBlocEvent, PokemonBlocState> {
  final IPokemonService _pokemonService;

  PokemonBlocBloc(this._pokemonService) : super(PokemonBlocInitial()) {
    on<FetchPokemonEvent>(onFetchPokemon);
  }

  FutureOr<void> onFetchPokemon(
      FetchPokemonEvent event, Emitter<PokemonBlocState> emit) async {
        final name = PokemonName(event.pokemonName);
        if (!name.isValid()) {
          return;
        }
    emit(PokemonBlocLoading());
    final Either<Failure, Pokemon> result =
        await _pokemonService.getData(name);

  // Fold è un metodo della libreria di dartz che permette di gestire i due casi di successo e fallimento
    result.fold(
      (failure) => emit(PokemonBlocFailure(failure.message)),
      (pokemon) => emit(PokemonBlocSuccess(pokemon)),
    );
  }
}
