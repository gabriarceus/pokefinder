import 'package:bloc/bloc.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/2_application/helpers/log_sanitizer.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

part 'home_event.dart';
part 'home_state.dart';

const _prefix = 'HomeBloc';

/// Manages home screen state: search input, search validation and the
/// suggestion index.
@injectable
class HomeBloc extends Bloc<HomeBlocEvent, HomeBlocState> {
  HomeBloc(this._pokemonRepository, this._logger)
    : super(HomeBlocState.initial()) {
    on<SearchInputChanged>(_onSearchInputChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<LoadIndex>(_onLoadIndex);
    on<NavigationDone>(
      (event, emit) => emit(state.copyWith(pendingNavigation: null)),
    );
  }

  final IPokemonRepository _pokemonRepository;
  final EnLogger _logger;

  void _onSearchInputChanged(
    SearchInputChanged event,
    Emitter<HomeBlocState> emit,
  ) {
    final inputLog = sanitizeQueryForLog(event.input);
    _logger.info('User input: $inputLog', prefix: _prefix);
    emit(state.copyWith(userInput: event.input, searchFailure: null));
  }

  void _onSearchSubmitted(SearchSubmitted event, Emitter<HomeBlocState> emit) {
    final inputLog = sanitizeQueryForLog(event.input);
    _logger.info('Search submitted: $inputLog', prefix: _prefix);
    PokemonName(event.input).value.fold(
      (failure) =>
          emit(state.copyWith(userInput: event.input, searchFailure: failure)),
      (_) => emit(
        state.copyWith(
          userInput: event.input,
          searchFailure: null,
          pendingNavigation: SearchNavigation(event.input.trim()),
        ),
      ),
    );
  }

  Future<void> _onLoadIndex(
    LoadIndex event,
    Emitter<HomeBlocState> emit,
  ) async {
    emit(state.copyWith(isIndexLoading: true));
    final result = await _pokemonRepository.getPokemonIndex();
    result.fold(
      (failure) {
        _logger.error(
          'Failed to fetch pokemon index: $failure',
          prefix: _prefix,
        );
        emit(state.copyWith(indexFailure: failure, isIndexLoading: false));
      },
      (entries) => emit(
        state.copyWith(
          pokemonIndex: entries,
          indexFailure: null,
          isIndexLoading: false,
        ),
      ),
    );
  }
}
