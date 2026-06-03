import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_encounter/raw_encounter.dart';
import 'package:pokefinder/src/4_repository/models/raw_form_details/raw_form_details.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';
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
  Future<RawPokemon> getPokemon(PokemonName name) async {
    try {
      final json = await _dataRepository.fetchData(
        '$_kBaseUrl${name.rightOrCrash()}',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );

      return RawPokemon.fromJson(json as Map<String, dynamic>);
    } on DataFetchException {
      throw BadRequestFailure();
    } on PokemonFailure {
      rethrow;
    } catch (_) {
      throw BadRequestFailure();
    }
  }

  @override
  Future<RawFormDetails> getFormDetails(String url) async {
    try {
      final json = await _dataRepository.fetchData(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return RawFormDetails.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      throw BadRequestFailure();
    }
  }

  @override
  Future<List<RawEncounter>> getEncounters(String url) async {
    try {
      final json = await _dataRepository.fetchData(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return (json as List<dynamic>)
          .map((e) => RawEncounter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw BadRequestFailure();
    }
  }
}
