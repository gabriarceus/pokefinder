// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

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
import 'src/2_application/hydrated_bloc/language_storage.dart' as _i1056;
import 'src/3_domain/repositories/i_pokemon_repository.dart' as _i768;
import 'src/3_domain/usecases/get_pokemon_usecase.dart' as _i694;
import 'src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart'
    as _i725;
import 'src/4_repository/datasources/implementations/pokemon_remote_datasource.dart'
    as _i695;
import 'src/4_repository/repositories/mock_pokemon_repository.dart' as _i740;
import 'src/4_repository/repositories/pokemon_repository_impl.dart' as _i907;

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
    gh.factory<_i1056.LanguageCubit>(() => _i1056.LanguageCubit());
    gh.lazySingleton<_i463.EnLogger>(() => registerModule.logger);
    gh.lazySingleton<_i768.IPokemonRepository>(
      () => _i740.MockPokemonRepository(),
      registerFor: {_mock},
    );
    gh.lazySingleton<_i694.GetPokemonUseCase>(
        () => _i694.GetPokemonUseCase(gh<_i768.IPokemonRepository>()));
    gh.factory<_i1067.PokemonBloc>(() => _i1067.PokemonBloc(
          gh<_i694.GetPokemonUseCase>(),
          gh<_i463.EnLogger>(),
        ));
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i463.EnLogger>()));
    gh.lazySingleton<_i725.IPokemonRemoteDataSource>(
        () => _i695.PokemonRemoteDataSource(dio: gh<_i361.Dio>()));
    gh.lazySingleton<_i768.IPokemonRepository>(
      () => _i907.PokemonRepositoryImpl(gh<_i725.IPokemonRemoteDataSource>()),
      registerFor: {_prod},
    );
    return this;
  }
}

class _$RegisterModule extends _i261.RegisterModule {}
