import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:pokefinder/src/4_repository/models/raw_encounter/raw_encounter.dart';
import 'package:pokefinder/src/4_repository/models/raw_form_details/raw_form_details.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';
import 'package:pokefinder/src/4_repository/models/raw_move_detail/raw_move_detail.dart';

import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

abstract class IPokemonRemoteDataSource {
  Future<Either<PokemonFailure, RawPokemon>> getPokemon(
    PokemonName name, {
    CancelToken? cancelToken,
  });
  Future<Either<PokemonFailure, RawFormDetails>> getFormDetails(
    String url, {
    CancelToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<RawEncounter>>> getEncounters(
    String url, {
    CancelToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    CancelToken? cancelToken,
    bool forceRefresh = false,
  });
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type, {
    CancelToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames();
  Future<Either<PokemonFailure, RawMoveDetail>> getMoveDetail(String name);
  Future<Either<PokemonFailure, Unit>> clearCache();
  Future<Either<PokemonFailure, int>> getCacheSize();
}
