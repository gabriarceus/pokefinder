import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';

/// Filters [entries] returning up to [limit] matching names for [query] when trimmed length is at least [minLength].
List<String> filterIndexSuggestions(
  Iterable<PokemonIndexEntry> entries,
  String query, {
  int minLength = 2,
  int limit = 5,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.length < minLength) return const [];
  return entries
      .where(
        (entry) =>
            entry.name.toLowerCase().contains(normalized) ||
            entry.id.toString().startsWith(normalized) ||
            entry.formattedId.toLowerCase().contains(normalized),
      )
      .map((entry) => entry.name)
      .take(limit)
      .toList();
}
