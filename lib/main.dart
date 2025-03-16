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

/// True = English, False = Italian
bool language = true;
void main() {
  bootstrap(then: () => const MyApp());
}

// Bootstrap viene eseguito all'avvio dell'applicazione (può essere async)
void bootstrap({required Widget Function() then}) async {
  setup(useMock: false);
  configureDependencies();
  // Inizializza lo storage per HydratedBloc
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // Inizializza il printer
  final printer = PrinterHandler()
    ..configure({
      Severity.notice: const PrinterColor.green(),
    });

  // Inizializza il logger
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
// Il builder di GoRoute è un widget che viene costruito quando la route viene raggiunta.
// Accetta due parametri: il contesto e lo stato del router.
// Il BuildContext è un oggetto che contiene informazioni su dove si trova il widget nel widget tree.
// Il GoRouterState contiene informazioni sulla route corrente, come il percorso, i parametri e i parametri extra.
// Il builder di GoRoute deve restituire un widget (una pagina).
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
            // Viene estratto il nome del Pokémon dalla "map extra" e viene passato al Detail widget tramite il BlocProvider
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

//Ritorna un MaterialApp con il router configurato
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
