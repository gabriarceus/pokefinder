import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/models/raw_encounter/raw_encounter.dart';
import 'package:pokefinder/src/4_repository/models/raw_form_details/raw_form_details.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';

abstract class IPokemonRemoteDataSource {
  Future<RawPokemon> getPokemon(PokemonName name);
  Future<RawFormDetails> getFormDetails(String url);
  Future<List<RawEncounter>> getEncounters(String url);
}
