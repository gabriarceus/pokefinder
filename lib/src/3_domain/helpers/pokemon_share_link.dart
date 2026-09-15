import 'package:pokefinder/src/3_domain/helpers/pokemon_route_param_parser.dart';

/// Custom URL scheme backing sharable Pokémon deep links.
///
/// No extra Android/iOS permissions are required for a custom scheme; it is
/// declared through an intent filter (`AndroidManifest.xml`) and a URL type
/// (`Info.plist`) only.
const pokemonShareScheme = 'pokefinder';

/// Builds the canonical in-app path identifying [nameOrId] (e.g.
/// `/pokemon/pikachu`, `/pokemon/25`).
///
/// Returns `null` when [nameOrId] is not a valid Pokémon name or numeric ID.
String? buildPokemonCanonicalPath(String? nameOrId) {
  final validated = parsePokemonRouteParam(nameOrId);
  if (validated == null) return null;
  return '/pokemon/$validated';
}

/// Builds a sharable deep-link URI for [nameOrId] (e.g.
/// `pokefinder:///pokemon/pikachu`).
///
/// Returns `null` when [nameOrId] is not a valid Pokémon name or numeric ID.
Uri? buildPokemonShareUri(String? nameOrId) {
  final path = buildPokemonCanonicalPath(nameOrId);
  if (path == null) return null;
  return Uri(scheme: pokemonShareScheme, host: '', path: path);
}

/// Extracts the canonical Pokémon identifier from a shared link.
///
/// Accepts canonical paths (`/pokemon/pikachu`), deep-link URIs
/// (`pokefinder:///pokemon/25`), http(s) URLs containing a `/pokemon/`
/// segment (query strings and fragments are ignored), and bare identifiers
/// (`pikachu`, `25`). Returns the normalized identifier, or `null` for
/// invalid input.
String? parsePokemonShareLink(String? input) {
  if (input == null) return null;
  final text = input.trim();
  if (text.isEmpty) return null;

  const marker = '/pokemon/';
  final markerIndex = text.lastIndexOf(marker);
  if (markerIndex < 0) {
    return parsePokemonRouteParam(text);
  }

  final remainder = text.substring(markerIndex + marker.length);
  final end = remainder.indexOf(RegExp(r'[?#\s/]'));
  final candidate = end >= 0 ? remainder.substring(0, end) : remainder;
  return parsePokemonRouteParam(candidate);
}
