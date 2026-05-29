// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:en_logger/en_logger.dart' as _i463;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'bootstrap.dart' as _i261;
import 'src/2_application/bloc/detail_bloc/detail_bloc.dart' as _i1067;
import 'src/2_application/bloc/home_bloc/home_bloc.dart' as _i56;
import 'src/2_application/hydrated_bloc/language_storage.dart' as _i1056;
import 'src/3_domain/domain.dart' as _i341;
import 'src/3_domain/repositories/i_pokemon_repository.dart' as _i768;
import 'src/3_domain/usecases/get_pokemon_encounters_usecase.dart' as _i656;
import 'src/3_domain/usecases/get_pokemon_form_details_usecase.dart' as _i476;
import 'src/3_domain/usecases/get_pokemon_usecase.dart' as _i694;
import 'src/4_repository/datasources/abstract/api_client.dart' as _i13;
import 'src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart'
    as _i725;
import 'src/4_repository/datasources/abstract/local_storage.dart' as _i477;
import 'src/4_repository/datasources/implementations/dio_api_client.dart'
    as _i876;
import 'src/4_repository/datasources/implementations/hive_local_storage.dart'
    as _i222;
import 'src/4_repository/datasources/implementations/pokemon_remote_datasource.dart'
    as _i695;
import 'src/4_repository/repositories/data_repository.dart' as _i95;
import 'src/4_repository/repositories/mock_pokemon_repository.dart' as _i740;
import 'src/4_repository/repositories/pokemon_repository_impl.dart' as _i907;
import 'src/4_repository/repository.dart' as _i579;

const String _mock = 'mock';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i463.EnLogger>(() => registerModule.logger);
    gh.lazySingleton<_i341.IPokemonRepository>(
      () => _i740.MockPokemonRepository(),
      registerFor: {_mock},
    );
    gh.factory<_i1056.LanguageCubit>(
        () => _i1056.LanguageCubit(gh<_i463.EnLogger>()));
    gh.lazySingleton<_i477.LocalStorage>(() => _i222.HiveLocalStorage());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i463.EnLogger>()));
    gh.lazySingleton<_i13.ApiClient>(
        () => _i876.DioApiClient(dio: gh<_i361.Dio>()));
    gh.factory<_i95.DataRepository>(() => _i95.DataRepository(
          apiClient: gh<_i13.ApiClient>(),
          localStorage: gh<_i477.LocalStorage>(),
          logger: gh<_i463.EnLogger>(),
        ));
    gh.lazySingleton<_i725.IPokemonRemoteDataSource>(() =>
        _i695.PokemonRemoteDataSource(
            dataRepository: gh<_i95.DataRepository>()));
    gh.factory<_i56.HomeBloc>(() => _i56.HomeBloc(
          gh<_i95.DataRepository>(),
          gh<_i463.EnLogger>(),
        ));
    gh.lazySingleton<_i341.IPokemonRepository>(
      () => _i907.PokemonRepositoryImpl(gh<_i579.IPokemonRemoteDataSource>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i656.GetPokemonEncountersUseCase>(() =>
        _i656.GetPokemonEncountersUseCase(gh<_i768.IPokemonRepository>()));
    gh.lazySingleton<_i476.GetPokemonFormDetailsUseCase>(() =>
        _i476.GetPokemonFormDetailsUseCase(gh<_i768.IPokemonRepository>()));
    gh.lazySingleton<_i694.GetPokemonUseCase>(
        () => _i694.GetPokemonUseCase(gh<_i768.IPokemonRepository>()));
    gh.factory<_i1067.PokemonBloc>(() => _i1067.PokemonBloc(
          gh<_i694.GetPokemonUseCase>(),
          gh<_i656.GetPokemonEncountersUseCase>(),
          gh<_i476.GetPokemonFormDetailsUseCase>(),
          gh<_i463.EnLogger>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i261.RegisterModule {}
