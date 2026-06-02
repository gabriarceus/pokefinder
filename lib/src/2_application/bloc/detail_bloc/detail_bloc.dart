import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_usecase.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_encounters_usecase.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_form_details_usecase.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

export 'detail_moves_cubit.dart';

part 'detail_event.dart';
part 'detail_state.dart';

const _prefix = 'DetailBloc';

/// Manages the state for fetching, displaying, and switching Pokémon forms.
@injectable
class PokemonBloc extends Bloc<PokemonBlocEvent, PokemonBlocState> {
  PokemonBloc(
    this._getPokemonUseCase,
    this._getPokemonEncountersUseCase,
    this._getPokemonFormDetailsUseCase,
    this._logger,
  ) : super(PokemonBlocInitial()) {
    on<FetchPokemonEvent>(onFetchPokemon);
    on<SelectPokemonFormEvent>(onSelectPokemonForm);
  }

  final GetPokemonUseCase _getPokemonUseCase;
  final GetPokemonEncountersUseCase _getPokemonEncountersUseCase;
  final GetPokemonFormDetailsUseCase _getPokemonFormDetailsUseCase;
  final EnLogger _logger;

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

    await result.fold(
      (failure) async {
        _logger.error('Failed to fetch Pokemon: ${failure.message}',
            prefix: _prefix);
        emit(PokemonBlocFailure(failure.message));
      },
      (pokemon) async {
        _logger.info('Successfully fetched Pokemon: ${pokemon.name}',
            prefix: _prefix);

        final defaultFormDetails = PokemonFormDetails(
          name: pokemon.name,
          type1: pokemon.type1,
          type2: pokemon.type2,
          typeImage1: pokemon.typeImage1,
          typeImage2: pokemon.typeImage2,
          spriteDefault: pokemon.sprite,
          spriteShiny: pokemon.spriteFrontShiny ?? pokemon.sprite,
          artworkDefault: pokemon.officialArtworkDefault ?? pokemon.sprite,
          artworkShiny: pokemon.officialArtworkShiny ??
              pokemon.spriteFrontShiny ??
              pokemon.sprite,
        );

        emit(PokemonBlocSuccess(
          pokemon: pokemon,
          selectedFormDetails: defaultFormDetails,
          isLoadingEncounters: true,
        ));

        // Fetch location area encounters in the background
        final encountersResult =
            await _getPokemonEncountersUseCase(pokemon.locationAreaEncounters);

        final currentState = state;
        if (currentState is PokemonBlocSuccess &&
            currentState.pokemon.id == pokemon.id) {
          encountersResult.fold(
            (failure) {
              emit(currentState.copyWith(
                isLoadingEncounters: false,
                encountersError: failure.message,
              ));
            },
            (encounters) {
              emit(currentState.copyWith(
                isLoadingEncounters: false,
                encounters: encounters,
              ));
            },
          );
        }
      },
    );
  }

  FutureOr<void> onSelectPokemonForm(
      SelectPokemonFormEvent event, Emitter<PokemonBlocState> emit) async {
    final currentState = state;
    if (currentState is! PokemonBlocSuccess) return;

    if (event.form.name == currentState.pokemon.name) {
      final defaultFormDetails = PokemonFormDetails(
        name: currentState.pokemon.name,
        type1: currentState.pokemon.type1,
        type2: currentState.pokemon.type2,
        typeImage1: currentState.pokemon.typeImage1,
        typeImage2: currentState.pokemon.typeImage2,
        spriteDefault: currentState.pokemon.sprite,
        spriteShiny: currentState.pokemon.spriteFrontShiny ??
            currentState.pokemon.sprite,
        artworkDefault: currentState.pokemon.officialArtworkDefault ??
            currentState.pokemon.sprite,
        artworkShiny: currentState.pokemon.officialArtworkShiny ??
            currentState.pokemon.spriteFrontShiny ??
            currentState.pokemon.sprite,
      );
      emit(currentState.copyWith(
        selectedFormDetails: defaultFormDetails,
        isLoadingForm: false,
        formError: null,
      ));
      return;
    }

    emit(currentState.copyWith(isLoadingForm: true, formError: null));

    final result = await _getPokemonFormDetailsUseCase(event.form.url);

    final updatedState = state;
    if (updatedState is! PokemonBlocSuccess) return;

    result.fold(
      (failure) {
        emit(updatedState.copyWith(
          isLoadingForm: false,
          formError: failure.message,
        ));
      },
      (details) {
        emit(updatedState.copyWith(
          selectedFormDetails: details,
          isLoadingForm: false,
          formError: null,
        ));
      },
    );
  }
}
