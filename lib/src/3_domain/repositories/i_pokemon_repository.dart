import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_species.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

abstract class IPokemonRepository {
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name);
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(String url);
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
    String url,
  );
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    bool forceRefresh = false,
  });
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type,
  );
  Future<Either<PokemonFailure, MoveDetail>> getMoveDetail(String name);
  Future<Either<PokemonFailure, PokemonSpecies>> getPokemonSpecies(String url);
  Future<Either<PokemonFailure, EvolutionChain>> getEvolutionChain(String url);
  Future<Either<PokemonFailure, AbilityDetail>> getAbilityDetail(String name);
  Future<Either<PokemonFailure, Unit>> clearCache();
  Future<Either<PokemonFailure, int>> getCacheSize();
}
