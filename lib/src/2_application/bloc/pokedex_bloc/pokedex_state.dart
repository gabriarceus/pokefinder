part of 'pokedex_bloc.dart';

/// Status of the Pokédex catalog index.
enum PokedexStatus { initial, loading, success, failure }

@immutable
final class PokedexState extends Equatable {
  const PokedexState({
    required this.status,
    required this.isRefreshing,
    required this.allEntries,
    required this.filteredEntries,
    required this.visibleEntries,
    required this.currentPage,
    required this.pageSize,
    required this.searchQuery,
    required this.selectedTypes,
    required this.selectedGeneration,
    required this.sortOrder,
    required this.typeIdMap,
    this.failure,
    this.randomPokemonToNavigate,
  });

  factory PokedexState.initial() {
    return const PokedexState(
      status: PokedexStatus.initial,
      isRefreshing: false,
      allEntries: [],
      filteredEntries: [],
      visibleEntries: [],
      currentPage: 1,
      pageSize: 24,
      searchQuery: '',
      selectedTypes: {},
      selectedGeneration: null,
      sortOrder: PokedexSortOrder.idAscending,
      typeIdMap: {},
      failure: null,
      randomPokemonToNavigate: null,
    );
  }

  final PokedexStatus status;
  final bool isRefreshing;
  final List<PokemonIndexEntry> allEntries;
  final List<PokemonIndexEntry> filteredEntries;
  final List<PokemonIndexEntry> visibleEntries;
  final int currentPage;
  final int pageSize;
  final String searchQuery;
  final Set<PokemonType> selectedTypes;
  final int? selectedGeneration;
  final PokedexSortOrder sortOrder;
  final Map<PokemonType, Set<int>> typeIdMap;
  final PokemonFailure? failure;
  final PokemonIndexEntry? randomPokemonToNavigate;

  bool get hasMore => visibleEntries.length < filteredEntries.length;
  int get totalCount => filteredEntries.length;
  int get activeFilterCount =>
      (selectedTypes.isNotEmpty ? selectedTypes.length : 0) +
      (selectedGeneration != null ? 1 : 0) +
      (sortOrder != PokedexSortOrder.idAscending ? 1 : 0);
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedTypes.isNotEmpty ||
      selectedGeneration != null ||
      sortOrder != PokedexSortOrder.idAscending;

  static const _unset = Object();

  PokedexState copyWith({
    PokedexStatus? status,
    bool? isRefreshing,
    List<PokemonIndexEntry>? allEntries,
    List<PokemonIndexEntry>? filteredEntries,
    List<PokemonIndexEntry>? visibleEntries,
    int? currentPage,
    int? pageSize,
    String? searchQuery,
    Set<PokemonType>? selectedTypes,
    Object? selectedGeneration = _unset,
    PokedexSortOrder? sortOrder,
    Map<PokemonType, Set<int>>? typeIdMap,
    Object? failure = _unset,
    Object? randomPokemonToNavigate = _unset,
  }) {
    return PokedexState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      visibleEntries: visibleEntries ?? this.visibleEntries,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedGeneration: identical(selectedGeneration, _unset)
          ? this.selectedGeneration
          : selectedGeneration as int?,
      sortOrder: sortOrder ?? this.sortOrder,
      typeIdMap: typeIdMap ?? this.typeIdMap,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as PokemonFailure?,
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
    visibleEntries,
    currentPage,
    pageSize,
    searchQuery,
    selectedTypes,
    selectedGeneration,
    sortOrder,
    typeIdMap,
    failure,
    randomPokemonToNavigate,
  ];
}
