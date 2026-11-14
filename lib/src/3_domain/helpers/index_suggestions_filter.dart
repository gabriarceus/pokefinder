import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_index_filter_helper.dart';

/// Filters [entries] returning up to [limit] matching names for [query] when trimmed length is at least [minLength].
List<String> filterIndexSuggestions(
  Iterable<PokemonIndexEntry> entries,
  String query, {
  int minLength = 2,
  int limit = 5,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.length < minLength) return const [];

  final matches =
      entries
          .where(
            (entry) =>
                entry.formCategory != PokemonFormCategory.cosmetic &&
                PokemonIndexFilterHelper.matchesQuery(entry, normalized),
          )
          .toList()
        ..sort(PokemonIndexFilterHelper.compareBySpecies);

  return matches.map((entry) => entry.name).take(limit).toList();
}
