import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
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
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<FetchPokemonEvent>(onFetchPokemon, transformer: restartable());
    on<SelectPokemonFormEvent>(onSelectPokemonForm, transformer: restartable());
    on<RetryPokemonEncountersEvent>(
      onRetryEncounters,
      transformer: restartable(),
    );
    on<ClearPokemonFormFailureEvent>(onClearFormFailure);
  }

  final GetPokemonUseCase _getPokemonUseCase;
  final GetPokemonEncountersUseCase _getPokemonEncountersUseCase;
  final GetPokemonFormDetailsUseCase _getPokemonFormDetailsUseCase;
  final EnLogger _logger;
  CancellationToken? _pokemonCancelToken;
  CancellationToken? _encountersCancelToken;
  CancellationToken? _formCancelToken;

  @override
  Future<void> close() {
    _pokemonCancelToken?.cancel('PokemonBloc closed');
    _encountersCancelToken?.cancel('PokemonBloc closed');
    _formCancelToken?.cancel('PokemonBloc closed');
    return super.close();
  }

  FutureOr<void> onFetchPokemon(
    FetchPokemonEvent event,
    Emitter<PokemonBlocState> emit,
  ) async {
    final name = PokemonName(event.pokemonName);
    if (!name.isValid()) {
      return;
    }

    _pokemonCancelToken?.cancel('Superseded by new FetchPokemonEvent');
    _encountersCancelToken?.cancel('Superseded by new FetchPokemonEvent');
    final pokemonToken = CancellationToken();
    _pokemonCancelToken = pokemonToken;

    emit(const PokemonBlocLoading());
    _logger.info(
      'Fetching data for Pokemon: ${name.rightOrCrash()}',
      prefix: _prefix,
    );
    final Either<PokemonFailure, Pokemon> result = await _getPokemonUseCase(
      name,
      cancelToken: pokemonToken,
    );

    if (pokemonToken.isCancelled || emit.isDone) return;

    await result.fold(
      (failure) async {
        if (failure is RequestCancelledFailure) return;
        _logger.error(
          'Failed to fetch Pokemon: ${failure.message}',
          prefix: _prefix,
        );
        emit(PokemonBlocFailure(failure));
      },
      (pokemon) async {
        if (pokemonToken.isCancelled || emit.isDone) return;
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

        final encountersToken = CancellationToken();
        _encountersCancelToken = encountersToken;

        // Fetch location area encounters in the background
        final encountersResult = await _getPokemonEncountersUseCase(
          pokemon.locationAreaEncounters,
          cancelToken: encountersToken,
        );

        if (encountersToken.isCancelled || emit.isDone) return;

        final currentState = state;
        if (currentState is PokemonBlocSuccess &&
            currentState.pokemon.id == pokemon.id) {
          encountersResult.fold(
            (failure) {
              if (failure is RequestCancelledFailure) return;
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

    _encountersCancelToken?.cancel(
      'Superseded by new RetryPokemonEncountersEvent',
    );
    final encountersToken = CancellationToken();
    _encountersCancelToken = encountersToken;

    emit(
      currentState.copyWith(isLoadingEncounters: true, encountersFailure: null),
    );

    _logger.info(
      'Retrying encounters for Pokemon: ${currentState.pokemon.name}',
      prefix: _prefix,
    );

    final encountersResult = await _getPokemonEncountersUseCase(
      currentState.pokemon.locationAreaEncounters,
      cancelToken: encountersToken,
    );

    if (encountersToken.isCancelled || emit.isDone) return;

    final latestState = state;
    if (latestState is PokemonBlocSuccess &&
        latestState.pokemon.id == currentState.pokemon.id) {
      encountersResult.fold(
        (failure) {
          if (failure is RequestCancelledFailure) return;
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

    _formCancelToken?.cancel('Superseded by new SelectPokemonFormEvent');

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

    final formToken = CancellationToken();
    _formCancelToken = formToken;

    emit(
      currentState.copyWith(
        isLoadingForm: true,
        formFailure: null,
        failedForm: null,
      ),
    );

    final result = await _getPokemonFormDetailsUseCase(
      event.form.url,
      cancelToken: formToken,
    );

    if (formToken.isCancelled || emit.isDone) return;

    final updatedState = state;
    if (updatedState is! PokemonBlocSuccess) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
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
