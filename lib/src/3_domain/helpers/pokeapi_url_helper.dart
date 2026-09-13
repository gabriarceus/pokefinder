/// Utility for extracting identifiers from PokéAPI resource URLs and building
/// canonical asset URLs.
class PokeApiUrlHelper {
  const PokeApiUrlHelper._();

  static const _kSpritesRoot =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/';

  /// Extracts the trailing numeric ID from a PokéAPI resource URL
  /// (e.g. "https://pokeapi.co/api/v2/pokemon/25/" -> 25).
  /// Returns -1 when the URL cannot be parsed.
  static int extractId(String url) {
    final trimmed = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final lastSlashIndex = trimmed.lastIndexOf('/');
    if (lastSlashIndex == -1) return -1;
    return int.tryParse(trimmed.substring(lastSlashIndex + 1)) ?? -1;
  }

  /// Builds the official artwork URL for the given numeric [id].
  static String officialArtworkUrl(int id, {bool shiny = false}) =>
      '${_kSpritesRoot}pokemon/other/official-artwork/${shiny ? 'shiny/' : ''}$id.png';

  /// Builds the pixel sprite URL for the given numeric [id].
  static String spriteUrl(int id) => '${_kSpritesRoot}pokemon/$id.png';

  /// Builds the type sprite URL for the given [typeId].
  static String typeSpriteUrl(int typeId) =>
      '${_kSpritesRoot}types/generation-viii/sword-shield/$typeId.png';
}
