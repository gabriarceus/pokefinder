/// Filters [items] returning up to [limit] prefix matches for [query]
/// when trimmed query length is at least [minLength].
List<String> filterPrefixSuggestions(
  Iterable<String> items,
  String query, {
  int minLength = 2,
  int limit = 5,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.length < minLength) return const [];
  return items
      .where((item) => item.toLowerCase().startsWith(normalized))
      .take(limit)
      .toList();
}
