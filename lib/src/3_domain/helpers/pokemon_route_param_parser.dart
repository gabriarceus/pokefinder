/// Safely validates and normalizes a Pokémon route identifier (name or numeric ID).
///
/// Returns the trimmed, lowercased canonical identifier if valid, or `null` if the
/// input is missing, blank, zero or negative, or contains invalid characters.
///
/// Supported formats:
/// - Numeric Pokédex IDs: positive integers (e.g. `25`, `1`, `1008`).
/// - Pokémon names: lowercase alphanumeric segments delimited by single hyphens
///   (e.g. `pikachu`, `ho-oh`, `tapu-koko`, `porygon2`).
final _numericIdRegex = RegExp(r'^[0-9]+$');
final _canonicalNameRegex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

String? parsePokemonRouteParam(String? input) {
  if (input == null) return null;
  final normalized = input.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  // Positive integer ID (zero and negative numbers are rejected)
  if (_numericIdRegex.hasMatch(normalized)) {
    final id = int.tryParse(normalized);
    if (id != null && id > 0) {
      return id.toString();
    }
    return null;
  }

  // Canonical name: alphanumeric words separated by single hyphens
  if (_canonicalNameRegex.hasMatch(normalized)) {
    return normalized;
  }

  return null;
}
