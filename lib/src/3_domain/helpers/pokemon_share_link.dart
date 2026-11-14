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
