import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';

abstract class IPokemonRemoteDataSource {
  Future<RawPokemon> getPokemon(PokemonName name);
}
