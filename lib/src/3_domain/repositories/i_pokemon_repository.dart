import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

abstract class IPokemonRepository {
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name);
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(String url);
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
      String url);
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames();
}
