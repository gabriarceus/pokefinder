import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/2_application/application.dart';

void main() {
  bootstrap(then: () => const MyApp());
}

// Bootstrap gets executed at the start of the application (it can be async)
void bootstrap({required Widget Function() then}) async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(Environment.prod);

  // Initialize Hive for local JSON caching
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  // Initialize media_kit as the audio backend to support OGG on iOS
  JustAudioMediaKit.ensureInitialized(iOS: true);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(then());
}

/// The route configuration. [MyApp]
// The GoRoute builder is a widget that is built when the route is reached.
// It accepts two parameters: the context and the router state.
// BuildContext contains information about where the widget is located in the widget tree.
// GoRouterState contains information about the current route, such as the path, parameters, and extra parameters.
// The GoRoute builder must return a widget (a page).
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePageProvider(
          userInput: '',
          child: HomePage(),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'detail',
          builder: (BuildContext context, GoRouterState state) {
            // The extra parameter is a map that contains the data passed to the route.
            // In this case, it contains the name of the Pokémon.
            final String pokemonName =
                (state.extra as Map<String, dynamic>)['pokemonName'] as String;
            return PokemonBlocProvider(
              pokemonName: pokemonName,
              child: Detail(pokemonName: pokemonName),
            );
          },
        ),
      ],
    ),
  ],
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LanguageCubit>(),
      child:
          BlocBuilder<LanguageCubit, LanguageState>(builder: (context, state) {
        return MaterialApp.router(
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: state.locale,
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
