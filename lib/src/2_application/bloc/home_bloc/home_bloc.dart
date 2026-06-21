import 'package:bloc/bloc.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repositories/data_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

const _prefix = 'HomeBloc';

/// Manages home screen state: user search input, navigation, and cache clearing.
@injectable
class HomeBloc extends Bloc<HomeBlocEvent, HomeBlocState> {
  HomeBloc(this._pokemonRepository, this._dataRepository, this._logger)
      : super(HomeBlocState.initial()) {
    on<UserInputEvent>((event, emit) {
      _logger.info('User input: ${event.userInput}', prefix: _prefix);

      List<String> suggestions = [];
      if (event.userInput.length >= 2) {
        final query = event.userInput.toLowerCase();
        suggestions = state.allPokemonNames
            .where((name) => name.toLowerCase().startsWith(query))
            .take(5)
            .toList();
      }

      emit(state.copyWith(
        userInput: event.userInput,
        searchSuggestions: suggestions,
        failure: null,
      ));
    });

    on<FetchAllPokemonNamesEvent>((event, emit) async {
      final result = await _pokemonRepository.getAllPokemonNames();
      result.fold(
        (failure) => _logger.error('Failed to fetch pokemon names: $failure',
            prefix: _prefix),
        (names) => emit(state.copyWith(allPokemonNames: names)),
      );
    });

    on<IsButtonPressedEvent>((event, emit) {
      _logger.info('Search button pressed with input: ${state.userInput}',
          prefix: _prefix);
      final name = PokemonName(state.userInput);
      if (name.isValid()) {
        emit(state.copyWith(navigateToDetail: true, failure: null));
      } else {
        final failure = name.value.fold((l) => l, (r) => null);
        if (failure != null) {
          emit(state.copyWith(
            navigateToDetail: false,
            failure: failure,
          ));
        }
      }
    });

    on<ClearCacheEvent>((event, emit) async {
      _logger.info('Clearing repository cache', prefix: _prefix);
      await _dataRepository.clearCache();
      emit(state.copyWith(cacheCleared: true, failure: null));
      emit(state.copyWith(cacheCleared: false)); // Reset the flag
    });

    on<NavigationDoneEvent>((event, emit) {
      emit(state.copyWith(navigateToDetail: false, failure: null));
    });
  }

  final IPokemonRepository _pokemonRepository;
  final DataRepository _dataRepository;
  final EnLogger _logger;
}
