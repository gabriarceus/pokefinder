import 'package:en_logger/en_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/services/i_pokemon_service.dart';
import 'package:pokefinder/src/4_repository/services/pokemon_service.dart';
import 'package:pokefinder/src/4_repository/services/mock_pokemon_service.dart';
import 'package:pokefinder/bootstrap.config.dart';

import 'src/2_application/bloc/detail_bloc/detail_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();

// `useMock` is a flag to use mock data
// lazy singletons are created only when requested
void setup({bool useMock = false}) {
  // Registra EnLogger come singleton
  getIt.registerLazySingleton<EnLogger>(() {
    final printer = PrinterHandler()
      ..configure({
        Severity.notice: const PrinterColor.green(),
      });

    return EnLogger(
      defaultPrefixFormat: const PrefixFormat(
        startFormat: '[',
        endFormat: ']',
      ),
    )..addHandler(printer);
  });

  if (useMock) {
    getIt.registerLazySingleton<IPokemonService>(() => MockPokemonService());
  } else {
    getIt.registerLazySingleton<IPokemonService>(() => PokemonService());
  }

  getIt.registerFactory<PokemonBloc>(
    () => PokemonBloc(
      getIt<IPokemonService>(),
      getIt<EnLogger>(),
    ),
  );
}
