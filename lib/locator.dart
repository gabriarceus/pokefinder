import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/services/i_pokemon_service.dart';
import 'package:pokefinder/services/pokemon_service.dart';
import 'package:pokefinder/services/mock_pokemon_service.dart';
import 'package:pokefinder/locator.config.dart';

import 'bloc_detail/detail_bloc_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default  
  preferRelativeImports: true, // default  
  asExtension: true, // default  
)

void configureDependencies() => getIt.init();  

//flag useMock per utilizzare i dati mockati
//i lazy singleton vengono creati solo quando vengono richiesti
void setup({bool useMock = false}) {
  if (useMock) {
    getIt.registerLazySingleton<IPokemonService>(() => MockPokemonService());
  } else {
    getIt.registerLazySingleton<IPokemonService>(() => PokemonService());
  }

  getIt.registerFactory<PokemonBlocBloc>(
    () => PokemonBlocBloc(
      getIt<IPokemonService>(),
    ),
  );
}
