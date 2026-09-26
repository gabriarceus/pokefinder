import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/type_matchup_chart.dart';

/// Locations of the application routes, for `context.push` and `context.go`.
abstract final class AppRoutes {
  static const home = '/';
  static const pokedex = '/pokedex';
  static const compare = '/compare';
  static const favorites = '/favorites';
  static const teams = '/teams';
  static const settings = '/settings';
  static const about = '/settings/about';

  /// Home with [query] prefilled in the search field.
  static String homeWithQuery(String query) =>
      query.isEmpty ? home : '/?query=${Uri.encodeQueryComponent(query)}';

  /// Detail of the Pokémon [nameOrId]; [search] records a recent search.
  static String pokemon(String nameOrId, {String? search}) {
    final path = '/pokemon/${Uri.encodeComponent(nameOrId)}';
    return search == null
        ? path
        : '$path?search=${Uri.encodeQueryComponent(search)}';
  }

  /// Detail of the team [teamId].
  static String team(String teamId) => '/teams/${Uri.encodeComponent(teamId)}';

  /// Matchup calculator preset with up to 2 [defending] battle types.
  static String matchups([List<PokemonType> defending = const []]) {
    final slugs = defending
        .where(TypeMatchupChart.battleTypes.contains)
        .take(2)
        .map((t) => t.apiName)
        .join(',');
    return slugs.isEmpty ? '/matchups' : '/matchups?types=$slugs';
  }
}
