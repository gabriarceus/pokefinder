// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:clock/clock.dart' as _i454;
import 'package:dio/dio.dart' as _i361;
import 'package:en_logger/en_logger.dart' as _i463;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'bootstrap.dart' as _i261;
import 'src/2_application/bloc/ability_detail_cubit/ability_detail_cubit.dart'
    as _i473;
import 'src/2_application/bloc/comparison_cubit/comparison_cubit.dart' as _i199;
import 'src/2_application/bloc/detail_bloc/detail_bloc.dart' as _i1067;
import 'src/2_application/bloc/evolution_cubit/evolution_cubit.dart' as _i338;
import 'src/2_application/bloc/favorites_cubit/favorites_cubit.dart' as _i716;
import 'src/2_application/bloc/home_bloc/home_bloc.dart' as _i56;
import 'src/2_application/bloc/language_cubit/language_cubit.dart' as _i336;
import 'src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart'
    as _i539;
import 'src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart' as _i820;
import 'src/2_application/bloc/preferences_cubit/preferences_cubit.dart'
    as _i361;
import 'src/2_application/bloc/recent_history_cubit/recent_history_cubit.dart'
    as _i991;
import 'src/2_application/bloc/species_cubit/species_cubit.dart' as _i18;
import 'src/2_application/bloc/teams_cubit/teams_cubit.dart' as _i238;
import 'src/3_domain/domain.dart' as _i341;
import 'src/3_domain/repositories/i_pokemon_repository.dart' as _i768;
import 'src/3_domain/services/cry_audio_controller.dart' as _i814;
import 'src/4_repository/datasources/abstract/api_client.dart' as _i13;
import 'src/4_repository/datasources/abstract/local_storage.dart' as _i477;
import 'src/4_repository/datasources/implementations/dio_api_client.dart'
    as _i876;
import 'src/4_repository/datasources/implementations/hive_local_storage.dart'
    as _i222;
import 'src/4_repository/datasources/implementations/poke_api_cache.dart'
    as _i308;
import 'src/4_repository/repositories/mock_pokemon_repository.dart' as _i740;
import 'src/4_repository/repositories/pokemon_repository_impl.dart' as _i907;
import 'src/4_repository/repository.dart' as _i579;
import 'src/4_repository/services/cry_audio_controller_impl.dart' as _i883;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i463.EnLogger>(() => registerModule.logger);
    gh.lazySingleton<_i454.Clock>(() => registerModule.clock);
    gh.factory<_i814.CryAudioController>(
      () => _i883.JustAudioCryController(gh<_i463.EnLogger>()),
    );
    gh.lazySingleton<_i336.LanguageCubit>(
      () => _i336.LanguageCubit(gh<_i463.EnLogger>()),
    );
    gh.lazySingleton<_i13.ApiClient>(
      () => _i876.DioApiClient(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i341.IPokemonRepository>(
      () => _i740.MockPokemonRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i463.EnLogger>()));
    gh.lazySingleton<_i716.FavoritesCubit>(
      () =>
          _i716.FavoritesCubit(gh<_i463.EnLogger>(), clock: gh<_i454.Clock>()),
    );
    gh.lazySingleton<_i991.RecentHistoryCubit>(
      () => _i991.RecentHistoryCubit(
        gh<_i463.EnLogger>(),
        clock: gh<_i454.Clock>(),
      ),
    );
    gh.lazySingleton<_i238.TeamsCubit>(
      () => _i238.TeamsCubit(gh<_i463.EnLogger>(), clock: gh<_i454.Clock>()),
    );
    gh.lazySingleton<_i477.LocalStorage>(
      () => _i222.HiveLocalStorage(clock: gh<_i454.Clock>()),
    );
    gh.lazySingleton<_i308.PokeApiCache>(
      () => _i308.PokeApiCache(
        apiClient: gh<_i13.ApiClient>(),
        localStorage: gh<_i477.LocalStorage>(),
        logger: gh<_i463.EnLogger>(),
        clock: gh<_i454.Clock>(),
      ),
    );
    gh.lazySingleton<_i341.IPokemonRepository>(
      () => _i907.PokemonRepositoryImpl(gh<_i579.PokeApiCache>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i199.ComparisonCubit>(
      () => _i199.ComparisonCubit(
        gh<_i463.EnLogger>(),
        gh<_i341.IPokemonRepository>(),
      ),
    );
    gh.lazySingleton<_i361.PreferencesCubit>(
      () => _i361.PreferencesCubit(
        gh<_i463.EnLogger>(),
        gh<_i341.IPokemonRepository>(),
      ),
    );
    gh.factoryParam<_i820.PokedexBloc, Duration?, dynamic>(
      (searchDebounceDuration, _) => _i820.PokedexBloc(
        gh<_i341.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
        searchDebounceDuration: searchDebounceDuration,
      ),
    );
    gh.factory<_i473.AbilityDetailCubit>(
      () => _i473.AbilityDetailCubit(
        gh<_i768.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
      ),
    );
    gh.factory<_i1067.PokemonDetailBloc>(
      () => _i1067.PokemonDetailBloc(
        gh<_i768.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
      ),
    );
    gh.factory<_i338.EvolutionCubit>(
      () => _i338.EvolutionCubit(
        gh<_i768.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
      ),
    );
    gh.factory<_i539.MoveDetailCubit>(
      () => _i539.MoveDetailCubit(
        gh<_i768.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
      ),
    );
    gh.factory<_i18.SpeciesCubit>(
      () => _i18.SpeciesCubit(
        gh<_i768.IPokemonRepository>(),
        gh<_i463.EnLogger>(),
      ),
    );
    gh.factory<_i56.HomeBloc>(
      () => _i56.HomeBloc(gh<_i341.IPokemonRepository>(), gh<_i463.EnLogger>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i261.RegisterModule {}
