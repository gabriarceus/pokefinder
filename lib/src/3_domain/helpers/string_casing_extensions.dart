/// String casing helpers for turning raw identifiers into display text.
extension StringCasingExtensions on String {
  /// Returns this string with its first character upper-cased and the rest
  /// left untouched. Empty strings are returned unchanged.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of every space-separated word, dropping
  /// empty segments so repeated spaces collapse into single spaces.
  String capitalizeWords() {
    return split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word.capitalize())
        .join(' ');
  }

  /// Replaces hyphens with spaces and capitalizes every resulting word,
  /// preserving empty segments. Turns API slugs (e.g. "ultra-sun") into
  /// display text (e.g. "Ultra Sun").
  String toDisplayCase() {
    return replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word.capitalize() : '')
        .join(' ');
  }
}
