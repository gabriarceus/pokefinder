import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
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
    PokemonName name, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dataRepository.fetchData<Map<String, dynamic>>(
        '$_kBaseUrl${name.rightOrCrash()}',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
        cancelToken: cancelToken,
      );
      final rawPokemon = RawPokemon.fromJson(
        response.data,
      ).copyWith(isStale: response.metadata.isStale);
      return right(rawPokemon);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, RawFormDetails>> getFormDetails(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dataRepository.fetchData<Map<String, dynamic>>(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
        cancelToken: cancelToken,
      );
      return right(RawFormDetails.fromJson(response.data));
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, List<RawEncounter>>> getEncounters(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dataRepository.fetchData<List<dynamic>>(
        url,
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
        cancelToken: cancelToken,
      );
      final list = response.data
          .map((e) => RawEncounter.fromJson(e as Map<String, dynamic>))
          .toList();
      return right(list);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  int _extractIdFromUrl(String url) {
    final trimmed = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final lastSlashIndex = trimmed.lastIndexOf('/');
    if (lastSlashIndex == -1) return -1;
    return int.tryParse(trimmed.substring(lastSlashIndex + 1)) ?? -1;
  }

  @override
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _dataRepository.fetchData<Map<String, dynamic>>(
        '$_kBaseUrl?limit=100000&offset=0',
        strategy: forceRefresh
            ? FetchStrategy.networkFirst
            : FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
        cancelToken: cancelToken,
      );
      final results = response.data['results'] as List<dynamic>;
      final entries = <PokemonIndexEntry>[];
      for (final raw in results) {
        final map = raw as Map<String, dynamic>;
        final name = map['name'] as String? ?? '';
        final url = map['url'] as String? ?? '';
        final id = _extractIdFromUrl(url);
        if (id > 0 && name.isNotEmpty) {
          entries.add(PokemonIndexEntry(id: id, name: name, detailUrl: url));
        }
      }
      return right(entries);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dataRepository.fetchData<Map<String, dynamic>>(
        'https://pokeapi.co/api/v2/type/${type.apiName}',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
        cancelToken: cancelToken,
      );
      final pokemonList =
          response.data['pokemon'] as List<dynamic>? ?? const [];
      final idSet = <int>{};
      for (final item in pokemonList) {
        final pokemonMap =
            (item as Map<String, dynamic>)['pokemon'] as Map<String, dynamic>?;
        if (pokemonMap != null) {
          final url = pokemonMap['url'] as String? ?? '';
          final id = _extractIdFromUrl(url);
          if (id > 0) {
            idSet.add(id);
          }
        }
      }
      return right(idSet);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames() async {
    final indexResult = await getPokemonIndex();
    return indexResult.map((entries) => entries.map((e) => e.name).toList());
  }

  @override
  Future<Either<PokemonFailure, RawMoveDetail>> getMoveDetail(
    String name,
  ) async {
    try {
      final response = await _dataRepository.fetchData<Map<String, dynamic>>(
        'https://pokeapi.co/api/v2/move/$name',
        strategy: FetchStrategy.cacheFirst,
        maxAge: _kDefaultMaxAge,
      );
      return right(RawMoveDetail.fromJson(response.data));
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, Unit>> clearCache() async {
    try {
      await _dataRepository.clearCache();
      return const Right(unit);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  @override
  Future<Either<PokemonFailure, int>> getCacheSize() async {
    try {
      final size = await _dataRepository.getCacheSize();
      return Right(size);
    } catch (error) {
      return left(_mapError(error));
    }
  }

  /// Translates a low-level error into a typed [PokemonFailure].
  PokemonFailure _mapError(Object error) {
    if (error is PokemonFailure) return error;

    if (error is ApiException) {
      if (error.isCancelled) {
        return const RequestCancelledFailure();
      }
      if (error.isConnectionError) {
        return const NetworkUnavailableFailure();
      }
      if (error.isTimeout) {
        return const RequestTimeoutFailure();
      }
      if (error.statusCode != null) {
        final code = error.statusCode!;
        if (code == 404) return const PokemonNotFoundFailure();
        if (code == 401) return const UnauthorizedFailure();
        if (code == 400) return const BadRequestFailure();
        if (code == 429) return const RateLimitedFailure();
        if (code >= 500 && code < 600) return ServerFailure(code);
      }
      return UnexpectedFailure(error.message);
    }

    if (error is SocketException) {
      return const NetworkUnavailableFailure();
    }
    if (error is FormatException ||
        error is TypeError ||
        error is EmptyResponseException) {
      return InvalidResponseFailure(error.toString());
    }
    if (error is HiveError) {
      return StorageFailure(error.message);
    }

    return UnexpectedFailure(error.toString());
  }
}
