import 'package:en_logger/en_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/bootstrap.config.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

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
    getIt.registerLazySingleton<IPokemonRepository>(
        () => MockPokemonRepository());
  } else {
    getIt.registerLazySingleton<IPokemonRemoteDataSource>(
        () => PokemonRemoteDataSource());
    getIt.registerLazySingleton<IPokemonRepository>(
      () => PokemonRepositoryImpl(getIt<IPokemonRemoteDataSource>()),
    );
  }

  getIt.registerLazySingleton<GetPokemonUseCase>(
    () => GetPokemonUseCase(getIt<IPokemonRepository>()),
  );

  getIt.registerFactory<PokemonBloc>(
    () => PokemonBloc(
      getIt<GetPokemonUseCase>(),
      getIt<EnLogger>(),
    ),
  );
}
