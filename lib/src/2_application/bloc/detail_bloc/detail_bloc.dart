import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
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
  ) : super(const PokemonBlocInitial()) {
    on<FetchPokemonEvent>(onFetchPokemon);
    on<SelectPokemonFormEvent>(onSelectPokemonForm);
    on<RetryPokemonEncountersEvent>(onRetryEncounters);
    on<ClearPokemonFormFailureEvent>(onClearFormFailure);
  }

  final GetPokemonUseCase _getPokemonUseCase;
  final GetPokemonEncountersUseCase _getPokemonEncountersUseCase;
  final GetPokemonFormDetailsUseCase _getPokemonFormDetailsUseCase;
  final EnLogger _logger;

  FutureOr<void> onFetchPokemon(
    FetchPokemonEvent event,
    Emitter<PokemonBlocState> emit,
  ) async {
    final name = PokemonName(event.pokemonName);
    if (!name.isValid()) {
      return;
    }
    emit(const PokemonBlocLoading());
    _logger.info(
      'Fetching data for Pokemon: ${name.rightOrCrash()}',
      prefix: _prefix,
    );
    final Either<PokemonFailure, Pokemon> result = await _getPokemonUseCase(
      name,
    );

    await result.fold(
      (failure) async {
        _logger.error(
          'Failed to fetch Pokemon: ${failure.message}',
          prefix: _prefix,
        );
        emit(PokemonBlocFailure(failure));
      },
      (pokemon) async {
        _logger.info(
          'Successfully fetched Pokemon: ${pokemon.name}',
          prefix: _prefix,
        );

        final defaultFormDetails = PokemonFormDetails.fromPokemon(pokemon);

        emit(
          PokemonBlocSuccess(
            pokemon: pokemon,
            selectedFormDetails: defaultFormDetails,
            isLoadingEncounters: true,
          ),
        );

        // Fetch location area encounters in the background
        final encountersResult = await _getPokemonEncountersUseCase(
          pokemon.locationAreaEncounters,
        );

        final currentState = state;
        if (currentState is PokemonBlocSuccess &&
            currentState.pokemon.id == pokemon.id) {
          encountersResult.fold(
            (failure) {
              emit(
                currentState.copyWith(
                  isLoadingEncounters: false,
                  encountersFailure: failure,
                ),
              );
            },
            (encounters) {
              emit(
                currentState.copyWith(
                  isLoadingEncounters: false,
                  encounters: encounters,
                  encountersFailure: null,
                ),
              );
            },
          );
        }
      },
    );
  }

  FutureOr<void> onRetryEncounters(
    RetryPokemonEncountersEvent event,
    Emitter<PokemonBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonBlocSuccess) return;

    emit(
      currentState.copyWith(isLoadingEncounters: true, encountersFailure: null),
    );

    _logger.info(
      'Retrying encounters for Pokemon: ${currentState.pokemon.name}',
      prefix: _prefix,
    );

    final encountersResult = await _getPokemonEncountersUseCase(
      currentState.pokemon.locationAreaEncounters,
    );

    final latestState = state;
    if (latestState is PokemonBlocSuccess &&
        latestState.pokemon.id == currentState.pokemon.id) {
      encountersResult.fold(
        (failure) {
          emit(
            latestState.copyWith(
              isLoadingEncounters: false,
              encountersFailure: failure,
            ),
          );
        },
        (encounters) {
          emit(
            latestState.copyWith(
              isLoadingEncounters: false,
              encounters: encounters,
              encountersFailure: null,
            ),
          );
        },
      );
    }
  }

  FutureOr<void> onSelectPokemonForm(
    SelectPokemonFormEvent event,
    Emitter<PokemonBlocState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonBlocSuccess) return;

    if (event.form.name == currentState.pokemon.name) {
      final defaultFormDetails = PokemonFormDetails.fromPokemon(
        currentState.pokemon,
      );
      emit(
        currentState.copyWith(
          selectedFormDetails: defaultFormDetails,
          isLoadingForm: false,
          formFailure: null,
          failedForm: null,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        isLoadingForm: true,
        formFailure: null,
        failedForm: null,
      ),
    );

    final result = await _getPokemonFormDetailsUseCase(event.form.url);

    final updatedState = state;
    if (updatedState is! PokemonBlocSuccess) return;

    result.fold(
      (failure) {
        emit(
          updatedState.copyWith(
            isLoadingForm: false,
            formFailure: failure,
            failedForm: event.form,
          ),
        );
      },
      (details) {
        emit(
          updatedState.copyWith(
            selectedFormDetails: details,
            isLoadingForm: false,
            formFailure: null,
            failedForm: null,
          ),
        );
      },
    );
  }

  FutureOr<void> onClearFormFailure(
    ClearPokemonFormFailureEvent event,
    Emitter<PokemonBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is PokemonBlocSuccess) {
      emit(currentState.copyWith(formFailure: null, failedForm: null));
    }
  }
}
