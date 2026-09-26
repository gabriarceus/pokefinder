import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/2_application/helpers/log_sanitizer.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

part 'pokedex_event.dart';
part 'pokedex_state.dart';

const _prefix = 'PokedexBloc';

/// Manages Pokédex discovery browsing, client-side filtering and sorting.
@injectable
class PokedexBloc extends Bloc<PokedexEvent, PokedexState> {
  PokedexBloc(
    this._pokemonRepository,
    this._logger, {
    @factoryParam Duration? searchDebounceDuration,
  }) : _searchDebounce =
           searchDebounceDuration ?? const Duration(milliseconds: 250),
       super(const PokedexState()) {
    on<PokedexFetchIndexEvent>(_onFetchIndex);
    on<PokedexSearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: restartable(),
    );
    on<PokedexTypeFilterToggledEvent>(
      _onTypeFilterToggled,
      transformer: sequential(),
    );
    on<PokedexGenerationFilterChangedEvent>(
      (event, emit) => _applyFilters(
        emit,
        state.filters.copyWith(generation: event.generation),
      ),
    );
    on<PokedexSortOrderChangedEvent>(
      (event, emit) => _applyFilters(
        emit,
        state.filters.copyWith(sortOrder: event.sortOrder),
      ),
    );
    on<PokedexFormFilterChangedEvent>(
      (event, emit) => _applyFilters(
        emit,
        state.filters.copyWith(formFilter: event.formFilter),
      ),
    );
    on<PokedexCosmeticToggleChangedEvent>(
      (event, emit) => _applyFilters(
        emit,
        state.filters.copyWith(
          includeCosmeticForms: event.includeCosmeticForms,
        ),
      ),
    );
    on<PokedexClearFiltersEvent>(
      (event, emit) => _applyFilters(emit, const PokedexFilters()),
    );
    on<PokedexSelectRandomPokemonEvent>(_onSelectRandomPokemon);
    on<PokedexRandomNavigationDoneEvent>(
      (event, emit) => emit(state.copyWith(randomPokemonToNavigate: null)),
    );
  }

  final IPokemonRepository _pokemonRepository;
  final EnLogger _logger;
  final Duration _searchDebounce;
  final Random _random = Random();

  /// Emits [filters] with the entries they select.
  void _applyFilters(Emitter<PokedexState> emit, PokedexFilters filters) {
    if (filters == state.filters) return;
    _logger.info('Filters changed: $filters', prefix: _prefix);
    emit(
      state.copyWith(
        filters: filters,
        filteredEntries: _filter(state.allEntries, filters, state.typeIdMap),
      ),
    );
  }

  List<PokemonIndexEntry> _filter(
    List<PokemonIndexEntry> entries,
    PokedexFilters filters,
    Map<PokemonType, Set<int>> typeIdMap,
  ) {
    return PokemonIndexFilterHelper.filterAndSort(
      entries: entries,
      query: filters.query,
      generation: filters.generation,
      selectedTypes: filters.selectedTypes,
      typeIdMap: typeIdMap,
      sortOrder: filters.sortOrder,
      formFilter: filters.formFilter,
      includeCosmeticForms: filters.includeCosmeticForms,
    );
  }

  Future<void> _onFetchIndex(
    PokedexFetchIndexEvent event,
    Emitter<PokedexState> emit,
  ) async {
    _logger.info(
      'Fetching Pokédex index (forceRefresh: ${event.forceRefresh})',
      prefix: _prefix,
    );

    if (state.allEntries.isEmpty) {
      emit(state.copyWith(status: PokedexStatus.loading, failure: null));
    } else if (event.forceRefresh) {
      emit(state.copyWith(isRefreshing: true, failure: null));
    }

    final result = await _pokemonRepository.getPokemonIndex(
      forceRefresh: event.forceRefresh,
    );

    result.fold(
      (failure) {
        _logger.error(
          'Failed to fetch Pokédex index: $failure',
          prefix: _prefix,
        );
        emit(
          state.copyWith(
            status: state.allEntries.isEmpty ? PokedexStatus.failure : null,
            isRefreshing: false,
            failure: failure,
          ),
        );
      },
      (entries) => emit(
        state.copyWith(
          status: PokedexStatus.success,
          isRefreshing: false,
          allEntries: entries,
          filteredEntries: _filter(entries, state.filters, state.typeIdMap),
          failure: null,
        ),
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    PokedexSearchQueryChangedEvent event,
    Emitter<PokedexState> emit,
  ) async {
    if (event.query == state.filters.query) return;
    // Debounce: restartable() drops this handler when a newer query arrives.
    if (event.query.isNotEmpty && _searchDebounce > Duration.zero) {
      await Future<void>.delayed(_searchDebounce);
      if (emit.isDone) return;
    }
    final queryLog = sanitizeQueryForLog(event.query);
    _logger.info('Search query changed: $queryLog', prefix: _prefix);
    _applyFilters(emit, state.filters.copyWith(query: event.query));
  }

  Future<void> _onTypeFilterToggled(
    PokedexTypeFilterToggledEvent event,
    Emitter<PokedexState> emit,
  ) async {
    final type = event.type;
    final selected = state.filters.selectedTypes;
    final isAdding = !selected.contains(type);
    _logger.info(
      'Type filter toggled: ${type.name} (active: $isAdding)',
      prefix: _prefix,
    );

    final toggledFilters = state.filters.copyWith(
      selectedTypes: isAdding
          ? {...selected, type}
          : ({...selected}..remove(type)),
    );
    if (!isAdding || state.typeIdMap.containsKey(type)) {
      _applyFilters(emit, toggledFilters);
      return;
    }

    // Show the selection at once; the grid keeps its entries until the ids
    // for this type arrive.
    emit(
      state.copyWith(
        filters: toggledFilters,
        loadingTypes: {...state.loadingTypes, type},
        typeFilterFailure: null,
      ),
    );

    final result = await _pokemonRepository.getPokemonIdsForType(type);
    final loadingTypes = {...state.loadingTypes}..remove(type);

    result.fold(
      (failure) {
        _logger.warning(
          'Could not load IDs for type ${type.name}: $failure',
          prefix: _prefix,
        );
        emit(
          state.copyWith(
            filters: state.filters.copyWith(
              selectedTypes: {...state.filters.selectedTypes}..remove(type),
            ),
            loadingTypes: loadingTypes,
            typeFilterFailure: failure,
          ),
        );
      },
      (ids) {
        final typeIdMap = {...state.typeIdMap, type: ids};
        emit(
          state.copyWith(
            typeIdMap: typeIdMap,
            loadingTypes: loadingTypes,
            filteredEntries: _filter(
              state.allEntries,
              state.filters,
              typeIdMap,
            ),
          ),
        );
      },
    );
  }

  void _onSelectRandomPokemon(
    PokedexSelectRandomPokemonEvent event,
    Emitter<PokedexState> emit,
  ) {
    final pool = state.filteredEntries.isNotEmpty
        ? state.filteredEntries
        : state.allEntries;
    if (pool.isEmpty) return;

    final chosen = pool[_random.nextInt(pool.length)];
    _logger.info('Random Pokémon selected: ${chosen.name}', prefix: _prefix);
    emit(state.copyWith(randomPokemonToNavigate: chosen));
  }
}
