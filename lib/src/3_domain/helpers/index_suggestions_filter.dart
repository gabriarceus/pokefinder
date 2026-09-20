import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';

/// Filters [entries] returning up to [limit] matching names for [query] when trimmed length is at least [minLength].
List<String> filterIndexSuggestions(
  Iterable<PokemonIndexEntry> entries,
  String query, {
  int minLength = 2,
  int limit = 5,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.length < minLength) return const [];

  final matches = entries.where((entry) {
    if (entry.formCategory == PokemonFormCategory.cosmetic) return false;

    final matchesName =
        entry.name.toLowerCase().contains(normalized) ||
        entry.displayName.toLowerCase().contains(normalized) ||
        entry.effectiveParentSpeciesName.toLowerCase().contains(normalized);
    final matchesId =
        entry.id.toString().startsWith(normalized) ||
        entry.formattedId.toLowerCase().contains(normalized) ||
        entry.dexNumberDisplay.toLowerCase().contains(normalized) ||
        entry.effectiveParentSpeciesId.toString().startsWith(normalized);
    final matchesCategory = switch (normalized) {
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

    return matchesName || matchesId || matchesCategory;
  }).toList();

  matches.sort((a, b) {
    final parentComp = a.effectiveParentSpeciesId.compareTo(
      b.effectiveParentSpeciesId,
    );
    if (parentComp != 0) return parentComp;
    if (!a.isAlternateForm && b.isAlternateForm) return -1;
    if (a.isAlternateForm && !b.isAlternateForm) return 1;
    return a.id.compareTo(b.id);
  });

  return matches.map((entry) => entry.name).take(limit).toList();
}
