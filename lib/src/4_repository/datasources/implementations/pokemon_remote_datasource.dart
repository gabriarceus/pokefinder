import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_encounter/raw_encounter.dart';
import 'package:pokefinder/src/4_repository/models/raw_form_details/raw_form_details.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';
import 'package:pokefinder/src/4_repository/models/raw_move_detail/raw_move_detail.dart';
import 'package:pokefinder/src/4_repository/repositories/data_repository.dart';
import 'package:pokefinder/src/4_repository/repositories/fetch_strategy.dart';

/// Default time-to-live for cached Pokemon data.
///
/// Pokemon stats and attributes rarely change, so a 24-hour window
/// provides a good balance between freshness and performance.
const _kDefaultMaxAge = Duration(hours: 24);

/// Base URL for the PokeAPI v2 Pokemon endpoint.
const _kBaseUrl = 'https://pokeapi.co/api/v2/pokemon/';

@LazySingleton(as: IPokemonRemoteDataSource)
class PokemonRemoteDataSource implements IPokemonRemoteDataSource {
  PokemonRemoteDataSource({required DataRepository dataRepository})
      : _dataRepository = dataRepository;

  final DataRepository _dataRepository;

  @override
  Future<Either<PokemonFailure, RawPokemon>> getPokemon(
      PokemonName name) async {
    try {
      final json = await _dataRepository.fetchData(
        '$_kBaseUrl${name.rightOrCrash()}',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return right(RawPokemon.fromJson(json as Map<String, dynamic>));
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, RawFormDetails>> getFormDetails(
      String url) async {
    try {
      final json = await _dataRepository.fetchData(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return right(RawFormDetails.fromJson(json as Map<String, dynamic>));
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, List<RawEncounter>>> getEncounters(
      String url) async {
    try {
      final json = await _dataRepository.fetchData(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return right((json as List<dynamic>)
          .map((e) => RawEncounter.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames() async {
    try {
      final json = await _dataRepository.fetchData(
        '$_kBaseUrl?limit=100000',
        strategy: FetchStrategy.cacheFirst,
        maxAge: const Duration(days: 30),
      );
      final results =
          (json as Map<String, dynamic>)['results'] as List<dynamic>;
      return right(results
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList());
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, RawMoveDetail>> getMoveDetail(
      String name) async {
    try {
      final json = await _dataRepository.fetchData(
        'https://pokeapi.co/api/v2/move/$name',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return right(RawMoveDetail.fromJson(json as Map<String, dynamic>));
    } catch (error) {
      return left(_mapError(error));
    }
  }

  /// Translates a low-level error into a typed [PokemonFailure].
  ///
  /// Already-typed failures pass through unchanged; an [ApiException] is mapped
  /// by its HTTP status (401 → unauthorized, 400 → bad request); anything else
  /// becomes an [UnexpectedFailure] preserving the original cause.
  PokemonFailure _mapError(Object error) {
    if (error is PokemonFailure) return error;
    if (error is ApiException) {
      return switch (error.statusCode) {
        401 => UnauthorizedFailure(),
        400 => BadRequestFailure(),
        _ => UnexpectedFailure(error.message),
      };
    }
    return UnexpectedFailure(error.toString());
  }
}
