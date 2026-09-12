import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

part 'home_event.dart';
part 'home_state.dart';

const _prefix = 'HomeBloc';

/// Manages home screen state: user search input, navigation, and cache clearing.
@injectable
class HomeBloc extends Bloc<HomeBlocEvent, HomeBlocState> {
  HomeBloc(this._pokemonRepository, this._clearCacheUseCase, this._logger)
    : super(HomeBlocState.initial()) {
    on<UserInputEvent>((event, emit) {
      _logger.info('User input: ${event.userInput}', prefix: _prefix);

      emit(state.copyWith(userInput: event.userInput, failure: null));
    }, transformer: restartable());

    on<FetchAllPokemonNamesEvent>((event, emit) async {
      final result = await _pokemonRepository.getAllPokemonNames();
      result.fold(
        (failure) {
          _logger.error(
            'Failed to fetch pokemon names: $failure',
            prefix: _prefix,
          );
          emit(state.copyWith(nameIndexFailure: failure));
        },
        (names) => emit(
          state.copyWith(allPokemonNames: names, nameIndexFailure: null),
        ),
      );
    });

    on<IsButtonPressedEvent>((event, emit) {
      _logger.info(
        'Search button pressed with input: ${state.userInput}',
        prefix: _prefix,
      );
      final name = PokemonName(state.userInput);
      if (name.isValid()) {
        emit(state.copyWith(navigateToDetail: true, failure: null));
      } else {
        final failure = name.value.fold((l) => l, (r) => null);
        if (failure != null) {
          emit(state.copyWith(navigateToDetail: false, failure: failure));
        }
      }
    });

    on<ClearCacheEvent>((event, emit) async {
      _logger.info('Clearing repository cache', prefix: _prefix);
      final result = await _clearCacheUseCase();
      result.fold(
        (failure) {
          _logger.error(
            'Failed to clear repository cache: $failure',
            prefix: _prefix,
          );
          emit(state.copyWith(cacheCleared: false, failure: failure));
        },
        (_) {
          emit(state.copyWith(cacheCleared: true, failure: null));
          emit(state.copyWith(cacheCleared: false)); // Reset the flag
        },
      );
    });

    on<NavigationDoneEvent>((event, emit) {
      emit(state.copyWith(navigateToDetail: false, failure: null));
    });
  }

  final IPokemonRepository _pokemonRepository;
  final ClearCacheUseCase _clearCacheUseCase;
  final EnLogger _logger;
}
