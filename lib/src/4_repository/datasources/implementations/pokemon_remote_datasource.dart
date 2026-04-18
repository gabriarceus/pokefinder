import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';

@LazySingleton(as: IPokemonRemoteDataSource)
class PokemonRemoteDataSource implements IPokemonRemoteDataSource {
  PokemonRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<RawPokemon> getPokemon(PokemonName name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
          'https://pokeapi.co/api/v2/pokemon/${name.rightOrCrash()}');

      if (response.statusCode != 200) {
        throw BadRequestFailure();
      }

      return RawPokemon.fromJson(response.data!);
    } on DioException {
      throw BadRequestFailure();
    } on PokemonFailure {
      rethrow;
    } catch (_) {
      throw BadRequestFailure();
    }
  }
}
