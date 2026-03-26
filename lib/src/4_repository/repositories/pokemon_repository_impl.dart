import 'package:dartz/dartz.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';

const _kBasePath =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/';

class PokemonRepositoryImpl implements IPokemonRepository {
  PokemonRepositoryImpl(this._remoteDataSource);

  final IPokemonRemoteDataSource _remoteDataSource;

  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) async {
    try {
      final rawPokemon = await _remoteDataSource.getPokemon(name);
      return right(_toDomain(rawPokemon));
    } on PokemonFailure catch (failure) {
      return left(failure);
    } catch (_) {
      return left(BadRequestFailure());
    }
  }

  Pokemon _toDomain(RawPokemon rawPokemon) {
    String getTypeFromUrl(String typeUrl) {
      final lastSlashIndex = typeUrl.lastIndexOf('/');
      final trimmed = typeUrl.substring(0, lastSlashIndex);
      final previousSlashIndex = trimmed.lastIndexOf('/');
      return trimmed.substring(previousSlashIndex + 1);
    }

    final type1 = getTypeFromUrl(rawPokemon.types.first.type.url);
    final type2 = rawPokemon.types.length > 1
        ? getTypeFromUrl(rawPokemon.types[1].type.url)
        : null;

    final typeImage1 = '$_kBasePath$type1.png';
    final typeImage2 = type2 != null ? '$_kBasePath$type2.png' : '';

    final ability1 = rawPokemon.abilities.first.ability.name;
    final ability2 = rawPokemon.abilities.length > 1
        ? rawPokemon.abilities[1].ability.name
        : '';
    final ability3 = rawPokemon.abilities.length > 2
        ? rawPokemon.abilities[2].ability.name
        : '';

    return Pokemon(
      id: rawPokemon.id,
      name: rawPokemon.name,
      sprite: rawPokemon.sprites.frontDefault,
      ability1: ability1,
      ability2: ability2,
      ability3: ability3,
      weight: rawPokemon.weight,
      height: rawPokemon.height,
      typeImage1: typeImage1,
      typeImage2: typeImage2,
      type1: type1,
      type2: type2,
      cry: rawPokemon.cries.latest,
    );
  }
}
