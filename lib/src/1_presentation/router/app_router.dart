import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/pages/about/about_page.dart';
import 'package:pokefinder/src/1_presentation/pages/comparison/comparison_page.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/favorites/favorites_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/pokedex_browse/pokedex_browse_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
import 'package:pokefinder/src/1_presentation/pages/settings/settings_page.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_route_param_parser.dart';

/// Global application router instance.
final GoRouter appRouter = createAppRouter();

/// Builds the canonical mobile [GoRouter] configuration for PokéFinder.
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          final query = state.uri.queryParameters['query'] ?? '';
          return HomePageProvider(userInput: query, child: const HomePage());
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'pokemon/:nameOrId',
            name: 'pokemon_detail',
            builder: (BuildContext context, GoRouterState state) {
              final rawParam = state.pathParameters['nameOrId'];
              final validated = parsePokemonRouteParam(rawParam);
              if (validated == null) {
                return RouteErrorPage(rawParam: rawParam);
              }
              final searchQuery = state.uri.queryParameters['search'];
              return PokemonBlocProvider(
                pokemonName: validated,
                child: Detail(pokemonName: validated, searchQuery: searchQuery),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/pokedex',
        name: 'pokedex_browse',
        builder: (BuildContext context, GoRouterState state) {
          return const PokedexBrowsePageProvider(child: PokedexBrowsePage());
        },
      ),
      GoRoute(
        path: '/compare',
        name: 'comparison',
        builder: (BuildContext context, GoRouterState state) {
          return const ComparisonPage();
        },
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (BuildContext context, GoRouterState state) {
          return const FavoritesPage();
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsPage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (BuildContext context, GoRouterState state) {
              return const AboutPage();
            },
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return RouteErrorPage(rawParam: state.uri.path);
    },
  );
}
