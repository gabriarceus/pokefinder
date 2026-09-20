import 'dart:async';
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

EventTransformer<PokedexSearchQueryChangedEvent> _debounceSearch(
  Duration duration,
) {
  return (events, mapper) {
    if (duration == Duration.zero) {
      return events.asyncExpand(mapper);
    }
    StreamController<PokedexSearchQueryChangedEvent>? controller;
    Timer? timer;
    StreamSubscription<PokedexSearchQueryChangedEvent>? subscription;

    controller = StreamController<PokedexSearchQueryChangedEvent>(
      onListen: () {
        subscription = events.listen(
          (event) {
            timer?.cancel();
            if (event.query.isEmpty) {
              controller?.add(event);
            } else {
              timer = Timer(duration, () {
                controller?.add(event);
              });
            }
          },
          onError: controller?.addError,
          onDone: () {
            timer?.cancel();
            controller?.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription?.cancel();
      },
    );

    return controller.stream.asyncExpand(mapper);
  };
}

/// Manages Pokédex discovery browsing, client-side filtering, sorting, and pagination.
@injectable
class PokedexBloc extends Bloc<PokedexEvent, PokedexState> {
  PokedexBloc(
    this._pokemonRepository,
    this._logger, {
    @factoryParam Duration? searchDebounceDuration,
  }) : super(PokedexState.initial()) {
    final debounce =
        searchDebounceDuration ?? const Duration(milliseconds: 250);
    on<PokedexFetchIndexEvent>(_onFetchIndex);
    on<PokedexSearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: _debounceSearch(debounce),
    );
    on<PokedexTypeFilterToggledEvent>(_onTypeFilterToggled);
    on<PokedexGenerationFilterChangedEvent>(_onGenerationFilterChanged);
    on<PokedexSortOrderChangedEvent>(_onSortOrderChanged);
    on<PokedexFormFilterChangedEvent>(_onFormFilterChanged);
    on<PokedexCosmeticToggleChangedEvent>(_onCosmeticToggleChanged);
    on<PokedexClearFiltersEvent>(_onClearFilters);
    on<PokedexLoadMoreEvent>(_onLoadMore, transformer: droppable());
    on<PokedexSelectRandomPokemonEvent>(_onSelectRandomPokemon);
    on<PokedexRandomNavigationDoneEvent>(_onRandomNavigationDone);
  }

  final IPokemonRepository _pokemonRepository;
  final EnLogger _logger;
  final Random _random = Random();

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
        if (state.allEntries.isEmpty) {
          emit(
            state.copyWith(
              status: PokedexStatus.failure,
              failure: failure,
              isRefreshing: false,
            ),
          );
        } else {
          emit(state.copyWith(isRefreshing: false, failure: failure));
        }
      },
      (entries) {
        final filtered = PokemonIndexFilterHelper.filterAndSort(
          entries: entries,
          query: state.searchQuery,
          generation: state.selectedGeneration,
          selectedTypes: state.selectedTypes,
          typeIdMap: state.typeIdMap,
          sortOrder: state.sortOrder,
          formFilter: state.formFilter,
          includeCosmeticForms: state.includeCosmeticForms,
        );

        emit(
          state.copyWith(
            status: PokedexStatus.success,
            isRefreshing: false,
            allEntries: entries,
            filteredEntries: filtered,
            visibleEntries: filtered.take(state.pageSize).toList(),
            currentPage: 1,
            failure: null,
          ),
        );
      },
    );
  }

  void _onSearchQueryChanged(
    PokedexSearchQueryChangedEvent event,
    Emitter<PokedexState> emit,
  ) {
    if (event.query == state.searchQuery) return;
    final queryLog = sanitizeQueryForLog(event.query);
    _logger.info('Search query changed: $queryLog', prefix: _prefix);

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: event.query,
      generation: state.selectedGeneration,
      selectedTypes: state.selectedTypes,
      typeIdMap: state.typeIdMap,
      sortOrder: state.sortOrder,
      formFilter: state.formFilter,
      includeCosmeticForms: state.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  Future<void> _onTypeFilterToggled(
    PokedexTypeFilterToggledEvent event,
    Emitter<PokedexState> emit,
  ) async {
    final updatedTypes = Set<PokemonType>.from(state.selectedTypes);
    final isAdding = !updatedTypes.contains(event.type);

    if (isAdding) {
      updatedTypes.add(event.type);
    } else {
      updatedTypes.remove(event.type);
    }

    _logger.info(
      'Type filter toggled: ${event.type.name} (active: $isAdding)',
      prefix: _prefix,
    );

    var currentTypeIdMap = state.typeIdMap;
    PokemonFailure? typeFailure;

    // Fetch IDs for this type if missing from the cache map
    if (isAdding && !currentTypeIdMap.containsKey(event.type)) {
      final typeResult = await _pokemonRepository.getPokemonIdsForType(
        event.type,
      );
      typeResult.fold(
        (failure) {
          _logger.warning(
            'Could not load IDs for type ${event.type.name}: $failure',
            prefix: _prefix,
          );
          typeFailure = failure;
        },
        (ids) {
          currentTypeIdMap = Map<PokemonType, Set<int>>.from(currentTypeIdMap)
            ..[event.type] = ids;
        },
      );
    }

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: state.searchQuery,
      generation: state.selectedGeneration,
      selectedTypes: updatedTypes,
      typeIdMap: currentTypeIdMap,
      sortOrder: state.sortOrder,
      formFilter: state.formFilter,
      includeCosmeticForms: state.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        selectedTypes: updatedTypes,
        typeIdMap: currentTypeIdMap,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
        failure: typeFailure,
      ),
    );
  }

  void _onGenerationFilterChanged(
    PokedexGenerationFilterChangedEvent event,
    Emitter<PokedexState> emit,
  ) {
    if (event.generation == state.selectedGeneration) return;
    _logger.info(
      'Generation filter changed: ${event.generation}',
      prefix: _prefix,
    );

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: state.searchQuery,
      generation: event.generation,
      selectedTypes: state.selectedTypes,
      typeIdMap: state.typeIdMap,
      sortOrder: state.sortOrder,
      formFilter: state.formFilter,
      includeCosmeticForms: state.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        selectedGeneration: event.generation,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  void _onSortOrderChanged(
    PokedexSortOrderChangedEvent event,
    Emitter<PokedexState> emit,
  ) {
    if (event.sortOrder == state.sortOrder) return;
    _logger.info(
      'Sort order changed: ${event.sortOrder.name}',
      prefix: _prefix,
    );

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: state.searchQuery,
      generation: state.selectedGeneration,
      selectedTypes: state.selectedTypes,
      typeIdMap: state.typeIdMap,
      sortOrder: event.sortOrder,
      formFilter: state.formFilter,
      includeCosmeticForms: state.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        sortOrder: event.sortOrder,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  void _onFormFilterChanged(
    PokedexFormFilterChangedEvent event,
    Emitter<PokedexState> emit,
  ) {
    if (event.formFilter == state.formFilter) return;
    _logger.info(
      'Form filter changed: ${event.formFilter.name}',
      prefix: _prefix,
    );

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: state.searchQuery,
      generation: state.selectedGeneration,
      selectedTypes: state.selectedTypes,
      typeIdMap: state.typeIdMap,
      sortOrder: state.sortOrder,
      formFilter: event.formFilter,
      includeCosmeticForms: state.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        formFilter: event.formFilter,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  void _onCosmeticToggleChanged(
    PokedexCosmeticToggleChangedEvent event,
    Emitter<PokedexState> emit,
  ) {
    if (event.includeCosmeticForms == state.includeCosmeticForms) return;
    _logger.info(
      'Cosmetic forms toggle changed: ${event.includeCosmeticForms}',
      prefix: _prefix,
    );

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: state.searchQuery,
      generation: state.selectedGeneration,
      selectedTypes: state.selectedTypes,
      typeIdMap: state.typeIdMap,
      sortOrder: state.sortOrder,
      formFilter: state.formFilter,
      includeCosmeticForms: event.includeCosmeticForms,
    );

    emit(
      state.copyWith(
        includeCosmeticForms: event.includeCosmeticForms,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  void _onClearFilters(
    PokedexClearFiltersEvent event,
    Emitter<PokedexState> emit,
  ) {
    _logger.info('Clearing all Pokédex filters', prefix: _prefix);

    final filtered = PokemonIndexFilterHelper.filterAndSort(
      entries: state.allEntries,
      query: '',
      generation: null,
      selectedTypes: const {},
      typeIdMap: state.typeIdMap,
      sortOrder: PokedexSortOrder.idAscending,
      formFilter: PokedexFormFilter.canonicalOnly,
      includeCosmeticForms: false,
    );

    emit(
      state.copyWith(
        searchQuery: '',
        selectedTypes: const {},
        selectedGeneration: null,
        sortOrder: PokedexSortOrder.idAscending,
        formFilter: PokedexFormFilter.canonicalOnly,
        includeCosmeticForms: false,
        filteredEntries: filtered,
        visibleEntries: filtered.take(state.pageSize).toList(),
        currentPage: 1,
      ),
    );
  }

  Future<void> _onLoadMore(
    PokedexLoadMoreEvent event,
    Emitter<PokedexState> emit,
  ) async {
    if (!state.hasMore || state.status != PokedexStatus.success) return;

    final nextPage = state.currentPage + 1;
    final nextVisibleCount = nextPage * state.pageSize;
    final nextVisible = state.filteredEntries.take(nextVisibleCount).toList();

    _logger.info(
      'Loading page $nextPage (${nextVisible.length}/${state.filteredEntries.length} entries)',
      prefix: _prefix,
    );

    emit(state.copyWith(currentPage: nextPage, visibleEntries: nextVisible));
    await Future<void>.delayed(Duration.zero);
  }

  void _onSelectRandomPokemon(
    PokedexSelectRandomPokemonEvent event,
    Emitter<PokedexState> emit,
  ) {
    final pool = state.filteredEntries.isNotEmpty
        ? state.filteredEntries
        : state.allEntries;
    if (pool.isEmpty) return;

    final randomIndex = _random.nextInt(pool.length);
    final chosen = pool[randomIndex];

    _logger.info('Random Pokémon selected: ${chosen.name}', prefix: _prefix);
    emit(state.copyWith(randomPokemonToNavigate: chosen));
  }

  void _onRandomNavigationDone(
    PokedexRandomNavigationDoneEvent event,
    Emitter<PokedexState> emit,
  ) {
    emit(state.copyWith(randomPokemonToNavigate: null));
  }
}
