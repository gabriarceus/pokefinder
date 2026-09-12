import 'package:pokefinder/src/3_domain/entities/pokedex_sort_order.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Pure helper for filtering and sorting [PokemonIndexEntry] lists.
class PokemonIndexFilterHelper {
  const PokemonIndexFilterHelper._();

  /// Filters and sorts [entries] according to the given criteria.
  static List<PokemonIndexEntry> filterAndSort({
    required List<PokemonIndexEntry> entries,
    String query = '',
    int? generation,
    Set<PokemonType> selectedTypes = const {},
    Map<PokemonType, Set<int>> typeIdMap = const {},
    PokedexSortOrder sortOrder = PokedexSortOrder.idAscending,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    // Compute type matching ID set if types are selected and typeIdMap has entries
    Set<int>? allowedTypeIds;
    final hasAllSelectedTypesInMap =
        selectedTypes.isNotEmpty && selectedTypes.every(typeIdMap.containsKey);

    if (hasAllSelectedTypesInMap) {
      for (final type in selectedTypes) {
        final idsForType = typeIdMap[type]!;
        if (allowedTypeIds == null) {
          allowedTypeIds = Set<int>.from(idsForType);
        } else {
          allowedTypeIds = allowedTypeIds.intersection(idsForType);
        }
      }
    }

    final filtered = entries.where((entry) {
      // 1. Text Search: Prefix or contains match on name or ID match
      if (normalizedQuery.isNotEmpty) {
        final matchesName = entry.name.toLowerCase().contains(normalizedQuery);
        final matchesId =
            entry.id.toString().startsWith(normalizedQuery) ||
            entry.formattedId.toLowerCase().contains(normalizedQuery);
        if (!matchesName && !matchesId) {
          return false;
        }
      }

      // 2. Generation filter
      if (generation != null && generation > 0) {
        if (entry.generation != generation) {
          return false;
        }
      }

      // 3. Type filter
      if (selectedTypes.isNotEmpty) {
        if (entry.types.isNotEmpty) {
          final entryTypeSet = entry.types.toSet();
          if (!selectedTypes.every(entryTypeSet.contains)) {
            return false;
          }
        } else if (hasAllSelectedTypesInMap && allowedTypeIds != null) {
          if (!allowedTypeIds.contains(entry.id)) {
            return false;
          }
        } else {
          return false;
        }
      }

      return true;
    }).toList();

    switch (sortOrder) {
      case PokedexSortOrder.idAscending:
        filtered.sort((a, b) => a.id.compareTo(b.id));
      case PokedexSortOrder.idDescending:
        filtered.sort((a, b) => b.id.compareTo(a.id));
      case PokedexSortOrder.nameAscending:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case PokedexSortOrder.nameDescending:
        filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    return filtered;
  }
}
