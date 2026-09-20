import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_species.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';

import 'package:pokefinder/src/3_domain/cancellation_token.dart';

import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

abstract class IPokemonRepository {
  Future<Either<PokemonFailure, Pokemon>> getPokemon(
    PokemonName name, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(
    String url, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
    String url, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    CancellationToken? cancelToken,
    bool forceRefresh = false,
  });
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames();
  Future<Either<PokemonFailure, MoveDetail>> getMoveDetail(
    String name, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, PokemonSpecies>> getPokemonSpecies(
    String url, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, EvolutionChain>> getEvolutionChain(
    String url, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, AbilityDetail>> getAbilityDetail(
    String name, {
    CancellationToken? cancelToken,
  });
  Future<Either<PokemonFailure, Unit>> clearCache();
  Future<Either<PokemonFailure, int>> getCacheSize();
}
