import 'dart:convert';

import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/business_logic/hydrated_bloc/language_storage.dart';
import 'package:pokefinder/locator.dart';
import 'package:pokefinder/pages/detail/_bloc.dart';
import 'package:pokefinder/pages/home/_bloc.dart';
import 'package:pokefinder/pages/home/home_page.dart';
import 'package:pokefinder/pages/detail/detail_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  bootstrap(then: () => const MyApp());
}

// Bootstrap gets executed at the start of the application (it can be async)
void bootstrap({required Widget Function() then}) async {
  setup(useMock: false);
  configureDependencies();
  // HydratedBlocStorage configuration
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // Printer configuration
  final printer = PrinterHandler()
    ..configure({
      Severity.notice: const PrinterColor.green(),
    });

  // Logger configuration
  final logger = EnLogger(
      defaultPrefixFormat: const PrefixFormat(
    startFormat: '[]',
    endFormat: ']',
  ))
    ..addHandler(
      printer,
    )

    // debug log
    ..debug('a debug message')

    // error with data
    ..error(
      'error',
      data: [
        EnLoggerData(
          name: 'response',
          content: jsonEncode('BE data'),
          description: 'serialized BE response',
        ),
      ],
    );

  // logger instance with prefix
  logger.getConfiguredInstance(prefix: 'API Repository')

    // [API Repository] a debug message
    ..debug('a debug message')

    // [Custom prefix] a debug message
    ..error(
      'error',
      prefix: 'Custom prefix',
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
//FIXME: controllare che sia apposto
      create: (_) => LanguageCubit(),
      child: BlocBuilder<LanguageCubit, int>(builder: (context, state) {
        return MaterialApp.router(
          routerConfig: _router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: context.read<LanguageCubit>().getLanguageLocale(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
