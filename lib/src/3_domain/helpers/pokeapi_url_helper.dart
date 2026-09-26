/// Utility for extracting identifiers from PokéAPI resource URLs and building
/// canonical asset URLs.
class PokeApiUrlHelper {
  const PokeApiUrlHelper._();

  static const _kSpritesRoot =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/';

  static const _kApiRoot = 'https://pokeapi.co/api/v2/';

  /// Builds the `/pokemon/{nameOrId}` endpoint URL.
  static String pokemonUrl(String nameOrId) => '${_kApiRoot}pokemon/$nameOrId';

  /// Builds the endpoint URL that lists every Pokémon in one page.
  static String pokemonIndexUrl() =>
      '${_kApiRoot}pokemon/?limit=100000&offset=0';

  /// Builds the `/type/{name}` endpoint URL.
  static String typeUrl(String typeName) => '${_kApiRoot}type/$typeName';

  /// Builds the `/move/{name}` endpoint URL.
  static String moveUrl(String moveName) => '${_kApiRoot}move/$moveName';

  /// Builds the `/ability/{name}` endpoint URL.
  static String abilityUrl(String abilityName) =>
      '${_kApiRoot}ability/$abilityName';

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
}
