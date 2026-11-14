import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokedex_form_filter.dart';
import 'package:pokefinder/src/3_domain/entities/pokedex_sort_order.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Search text, filters and sort order applied to the Pokédex index.
class PokedexFilters extends Equatable {
  const PokedexFilters({
    this.query = '',
    this.selectedTypes = const {},
    this.generation,
    this.sortOrder = PokedexSortOrder.idAscending,
    this.formFilter = PokedexFormFilter.canonicalOnly,
    this.includeCosmeticForms = false,
  });

  static const _unset = Object();

  final String query;
  final Set<PokemonType> selectedTypes;

  /// Generation number from 1 to 9; null means every generation.
  final int? generation;
  final PokedexSortOrder sortOrder;
  final PokedexFormFilter formFilter;
  final bool includeCosmeticForms;

  /// Number of active filters and sort changes, without the search text.
  int get activeFilterCount =>
      selectedTypes.length +
      (generation != null ? 1 : 0) +
      (sortOrder != PokedexSortOrder.idAscending ? 1 : 0) +
      (formFilter != PokedexFormFilter.canonicalOnly ? 1 : 0) +
      (includeCosmeticForms ? 1 : 0);

  /// True when the search text or any filter differs from the defaults.
  bool get hasActiveFilters => query.isNotEmpty || activeFilterCount > 0;

  PokedexFilters copyWith({
    String? query,
    Set<PokemonType>? selectedTypes,
    Object? generation = _unset,
    PokedexSortOrder? sortOrder,
    PokedexFormFilter? formFilter,
    bool? includeCosmeticForms,
  }) {
    return PokedexFilters(
      query: query ?? this.query,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      generation: identical(generation, _unset)
          ? this.generation
          : generation as int?,
      sortOrder: sortOrder ?? this.sortOrder,
      formFilter: formFilter ?? this.formFilter,
      includeCosmeticForms: includeCosmeticForms ?? this.includeCosmeticForms,
    );
  }

  @override
  List<Object?> get props => [
    query,
    selectedTypes,
    generation,
    sortOrder,
    formFilter,
    includeCosmeticForms,
  ];
}
