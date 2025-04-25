import 'package:http/http.dart';
import 'dart:convert';
import 'package:pokefinder/models/pokemon.dart';
import 'package:pokefinder/services/i_pokemon_service.dart';
import 'package:pokefinder/services/raw_pokemon.dart';
import 'package:dartz/dartz.dart';

const _kBasePath =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/';

class PokemonService implements IPokemonService {
  // Using Either to handle success and failure. Failure is a class that contains an error message
  @override
  Future<Either<Failure, Pokemon>> getData(PokemonName pokemonName) async {
    try {
      Response response = await get(Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/${pokemonName.rightOrCrash()}'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return right(_pokemonFromJson(data));
      } else {
        return left(BadRequestFailure());
      }
    } catch (e) {
      return left(BadRequestFailure());
    }
  }

  Pokemon _pokemonFromJson(Map<String, dynamic> json) {
    final pokemon = RawPokemon.fromJson(json);

    String getTypeFromUrl(String typeUrl) {
      if (typeUrl[typeUrl.length - 3] == '/') {
        return typeUrl.substring(typeUrl.length - 2, typeUrl.length - 1);
      } else {
        return typeUrl.substring(typeUrl.length - 3, typeUrl.length - 1);
      }
    }

    // [rawType] is the url of the type, while [type] is the name of the type
    final rawType1 = json['types'][0]['type']['url'];
    final rawType2 =
        json['types'].length > 1 ? json['types'][1]['type']['url'] : '';
    final type1 = getTypeFromUrl(rawType1);
    final type2 = rawType2!.isNotEmpty ? getTypeFromUrl(rawType2) : null;

    final typeImage1 = "$_kBasePath$type1.png";
    final typeImage2 = type2 != null ? "$_kBasePath$type2.png" : '';

    final ability1 = json['abilities'][0]['ability']['name'];
    final ability2 = json['abilities'].length > 1
        ? json['abilities'][1]['ability']['name']
        : '';
    final ability3 = json['abilities'].length > 2
        ? json['abilities'][2]['ability']['name']
        : '';

    final sprite = json['sprites']['front_default'];

    final cry = json['cries']['latest'];

    return Pokemon(
      id: pokemon.id,
      name: pokemon.name,
      sprite: sprite,
      ability1: ability1,
      ability2: ability2,
      ability3: ability3,
      weight: pokemon.weight,
      height: pokemon.height,
      typeImage1: typeImage1,
      typeImage2: typeImage2,
      type1: type1,
      cry: cry,
    );
  }
}
