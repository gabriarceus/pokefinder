import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/2_application/helpers/log_sanitizer.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_summary.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_form_classifier.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

export 'detail_moves_cubit.dart';

part 'detail_event.dart';
part 'detail_state.dart';

const _prefix = 'DetailBloc';

/// Manages the state for fetching, displaying, and switching Pokémon forms.
@injectable
class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  PokemonDetailBloc(this._repository, this._logger)
    : super(const PokemonDetailInitial()) {
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

  final IPokemonRepository _repository;
  final EnLogger _logger;
  int _detailGeneration = 0;
  int _encountersGeneration = 0;

  FutureOr<void> onFetchPokemon(
    FetchPokemonEvent event,
    Emitter<PokemonDetailState> emit,
  ) async {
    final name = PokemonName(event.pokemonName);
    if (!name.isValid()) {
      return;
    }

    final generation = ++_detailGeneration;
    _encountersGeneration++;
    emit(const PokemonDetailLoading());
    _logger.info(
      'Fetching data for Pokemon: ${sanitizeQueryForLog(name.rightOrCrash())}',
      prefix: _prefix,
    );
    final Either<PokemonFailure, Pokemon> result = await _repository.getPokemon(
      name,
    );

    if (emit.isDone || generation != _detailGeneration) return;

    result.fold(
      (failure) {
        _logger.error(
          'Failed to fetch Pokemon: ${failure.message}',
          prefix: _prefix,
        );
        emit(PokemonDetailFailure(failure));
      },
      (pokemon) {
        _logger.info(
          'Successfully fetched Pokemon: ${pokemon.name}',
          prefix: _prefix,
        );

        final defaultFormDetails = PokemonFormDetails.fromPokemon(pokemon);

        emit(
          PokemonDetailSuccess(
            pokemon: pokemon,
            selectedFormDetails: defaultFormDetails,
            isLoadingEncounters: true,
          ),
        );

        add(RetryPokemonEncountersEvent());
      },
    );
  }

  FutureOr<void> onRetryEncounters(
    RetryPokemonEncountersEvent event,
    Emitter<PokemonDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonDetailSuccess) return;
    final generation = ++_encountersGeneration;

    emit(
      currentState.copyWith(isLoadingEncounters: true, encountersFailure: null),
    );

    _logger.info(
      'Retrying encounters for Pokemon: ${currentState.pokemon.name}',
      prefix: _prefix,
    );

    final encountersResult = await _repository.getEncounters(
      currentState.pokemon.locationAreaEncounters,
    );

    if (emit.isDone || generation != _encountersGeneration) return;

    final latestState = state;
    if (latestState is PokemonDetailSuccess &&
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
    Emitter<PokemonDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonDetailSuccess) return;

    final generation = ++_detailGeneration;

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

    final result = await _repository.getPokemon(PokemonName(event.form.name));

    if (emit.isDone || generation != _detailGeneration) return;

    final updatedState = state;
    if (updatedState is! PokemonDetailSuccess) return;

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
      (pokemon) {
        _encountersGeneration++;
        emit(
          updatedState.copyWith(
            pokemon: pokemon,
            selectedFormDetails: PokemonFormDetails.fromPokemon(pokemon),
            encounters: const [],
            isLoadingEncounters: true,
            encountersFailure: null,
            isLoadingForm: false,
            formFailure: null,
            failedForm: null,
          ),
        );
        add(RetryPokemonEncountersEvent());
      },
    );
  }

  FutureOr<void> onClearFormFailure(
    ClearPokemonFormFailureEvent event,
    Emitter<PokemonDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is PokemonDetailSuccess) {
      emit(currentState.copyWith(formFailure: null, failedForm: null));
    }
  }
}
