import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/pages/route_error/route_error_page.dart';
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
          return const HomePageProvider(userInput: '', child: HomePage());
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
              return PokemonBlocProvider(
                pokemonName: validated,
                child: Detail(pokemonName: validated),
              );
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
