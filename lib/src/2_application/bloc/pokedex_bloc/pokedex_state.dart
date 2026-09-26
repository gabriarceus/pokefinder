part of 'pokedex_bloc.dart';

/// Status of the Pokédex catalog index.
enum PokedexStatus { initial, loading, success, failure }

@immutable
final class PokedexState extends Equatable {
  const PokedexState({
    this.status = PokedexStatus.initial,
    this.isRefreshing = false,
    this.allEntries = const [],
    this.filteredEntries = const [],
    this.filters = const PokedexFilters(),
    this.typeIdMap = const {},
    this.loadingTypes = const {},
    this.failure,
    this.typeFilterFailure,
    this.randomPokemonToNavigate,
  });

  final PokedexStatus status;
  final bool isRefreshing;
  final List<PokemonIndexEntry> allEntries;

  /// [allEntries] after [filters] are applied.
  final List<PokemonIndexEntry> filteredEntries;
  final PokedexFilters filters;

  /// Pokémon ids per type, loaded on demand for the type filter.
  final Map<PokemonType, Set<int>> typeIdMap;

  /// Selected types whose ids are still loading.
  final Set<PokemonType> loadingTypes;

  /// Failure of the last index load.
  final PokemonFailure? failure;

  /// Failure of the last type-id load; the type is removed from the selection.
  final PokemonFailure? typeFilterFailure;
  final PokemonIndexEntry? randomPokemonToNavigate;

  static const _unset = Object();

  PokedexState copyWith({
    PokedexStatus? status,
    bool? isRefreshing,
    List<PokemonIndexEntry>? allEntries,
    List<PokemonIndexEntry>? filteredEntries,
    PokedexFilters? filters,
    Map<PokemonType, Set<int>>? typeIdMap,
    Set<PokemonType>? loadingTypes,
    Object? failure = _unset,
    Object? typeFilterFailure = _unset,
    Object? randomPokemonToNavigate = _unset,
  }) {
    return PokedexState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      filters: filters ?? this.filters,
      typeIdMap: typeIdMap ?? this.typeIdMap,
      loadingTypes: loadingTypes ?? this.loadingTypes,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as PokemonFailure?,
      typeFilterFailure: identical(typeFilterFailure, _unset)
          ? this.typeFilterFailure
          : typeFilterFailure as PokemonFailure?,
      randomPokemonToNavigate: identical(randomPokemonToNavigate, _unset)
          ? this.randomPokemonToNavigate
          : randomPokemonToNavigate as PokemonIndexEntry?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isRefreshing,
    allEntries,
    filteredEntries,
    filters,
    typeIdMap,
    loadingTypes,
    failure,
    typeFilterFailure,
    randomPokemonToNavigate,
  ];
}
