import 'package:pokefinder/src/3_domain/entities/pokedex_form_filter.dart';
import 'package:pokefinder/src/3_domain/entities/pokedex_sort_order.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';
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
    PokedexFormFilter formFilter = PokedexFormFilter.canonicalOnly,
    bool includeCosmeticForms = false,
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
      // 1. Cosmetic forms suppression
      if (!includeCosmeticForms &&
          entry.formCategory == PokemonFormCategory.cosmetic) {
        return false;
      }

      // 2. Form Category filter
      switch (formFilter) {
        case PokedexFormFilter.canonicalOnly:
          if (normalizedQuery.isEmpty && entry.isAlternateForm) {
            return false;
          }
        case PokedexFormFilter.all:
          break;
        case PokedexFormFilter.mega:
          if (entry.formCategory != PokemonFormCategory.mega &&
              entry.formCategory != PokemonFormCategory.primal) {
            return false;
          }
        case PokedexFormFilter.regional:
          if (entry.formCategory != PokemonFormCategory.regional) {
            return false;
          }
        case PokedexFormFilter.gmax:
          if (entry.formCategory != PokemonFormCategory.gmax) {
            return false;
          }
      }

      // 3. Text Search: natural searches ("mega", "alola", species name, ID)
      if (normalizedQuery.isNotEmpty) {
        final matchesName =
            entry.name.toLowerCase().contains(normalizedQuery) ||
            entry.displayName.toLowerCase().contains(normalizedQuery) ||
            entry.effectiveParentSpeciesName.toLowerCase().contains(
              normalizedQuery,
            );
        final matchesId =
            entry.id.toString().startsWith(normalizedQuery) ||
            entry.formattedId.toLowerCase().contains(normalizedQuery) ||
            entry.dexNumberDisplay.toLowerCase().contains(normalizedQuery) ||
            entry.effectiveParentSpeciesId.toString().startsWith(
              normalizedQuery,
            );
        final matchesCategory = switch (normalizedQuery) {
          'mega' => entry.formCategory == PokemonFormCategory.mega,
          'primal' => entry.formCategory == PokemonFormCategory.primal,
          'gmax' => entry.formCategory == PokemonFormCategory.gmax,
          'regional' => entry.formCategory == PokemonFormCategory.regional,
          'alola' => entry.regionalGroup == PokemonRegionalGroup.alola,
          'galar' => entry.regionalGroup == PokemonRegionalGroup.galar,
          'hisui' => entry.regionalGroup == PokemonRegionalGroup.hisui,
          'paldea' => entry.regionalGroup == PokemonRegionalGroup.paldea,
          _ => false,
        };

        if (!matchesName && !matchesId && !matchesCategory) {
          return false;
        }
      }

      // 4. Dual generation filter (parent species generation or introduction generation)
      if (generation != null && generation > 0) {
        final matchesGen =
            entry.generation == generation ||
            entry.effectiveSpeciesGeneration == generation ||
            entry.effectiveIntroductionGeneration == generation;
        if (!matchesGen) {
          return false;
        }
      }

      // 5. Type filter
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

    // 6. Interleaved sorting: alternate forms sorted directly beneath parent species
    switch (sortOrder) {
      case PokedexSortOrder.idAscending:
        filtered.sort((a, b) {
          final parentComp = a.effectiveParentSpeciesId.compareTo(
            b.effectiveParentSpeciesId,
          );
          if (parentComp != 0) return parentComp;
          if (!a.isAlternateForm && b.isAlternateForm) return -1;
          if (a.isAlternateForm && !b.isAlternateForm) return 1;
          return a.id.compareTo(b.id);
        });
      case PokedexSortOrder.idDescending:
        filtered.sort((a, b) {
          final parentComp = b.effectiveParentSpeciesId.compareTo(
            a.effectiveParentSpeciesId,
          );
          if (parentComp != 0) return parentComp;
          if (!a.isAlternateForm && b.isAlternateForm) return -1;
          if (a.isAlternateForm && !b.isAlternateForm) return 1;
          return b.id.compareTo(a.id);
        });
      case PokedexSortOrder.nameAscending:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case PokedexSortOrder.nameDescending:
        filtered.sort((a, b) => b.name.compareTo(a.name));
    }

    return filtered;
  }
}
