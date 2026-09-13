/// Utility for cleaning and normalizing text received from external sources.
class TextNormalizer {
  const TextNormalizer._();

  /// Normalizes formatting artifacts (form feeds, carriage returns, broken linefeeds)
  /// and collapses consecutive whitespace characters into a single space.
  static String cleanPokeApiText(String text) {
    if (text.isEmpty) return '';

    return text
        .replaceAll(RegExp(r'[\f\r\n\t]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
