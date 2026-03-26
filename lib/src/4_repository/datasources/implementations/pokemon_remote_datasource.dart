import 'dart:convert';

import 'package:http/http.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';

class PokemonRemoteDataSource implements IPokemonRemoteDataSource {
  PokemonRemoteDataSource({Client? client}) : _client = client ?? Client();

  final Client _client;

  @override
  Future<RawPokemon> getPokemon(PokemonName name) async {
    try {
      final response = await _client.get(Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/${name.rightOrCrash()}'));

      if (response.statusCode != 200) {
        throw BadRequestFailure();
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RawPokemon.fromJson(data);
    } on PokemonFailure {
      rethrow;
    } catch (_) {
      throw BadRequestFailure();
    }
  }
}
