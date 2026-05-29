import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

const _kBasePath =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield/';

@LazySingleton(as: IPokemonRepository, env: [Environment.prod])
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
    final type1 = _getTypeFromUrl(rawPokemon.types.first.type.url);
    final type2 = rawPokemon.types.length > 1
        ? _getTypeFromUrl(rawPokemon.types[1].type.url)
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

    final stats = rawPokemon.stats.map((s) => s.baseStat).toList();

    final abilities = rawPokemon.abilities
        .map((a) => PokemonAbility(
              name: a.ability.name,
              isHidden: a.isHidden,
              slot: a.slot,
            ))
        .toList();

    final heldItems = rawPokemon.heldItems
        .expand((item) => item.versionDetails.map((detail) => PokemonHeldItem(
              name: item.item.name,
              rarity: detail.rarity,
              version: detail.version.name,
            )))
        .toList();

    final moves = rawPokemon.moves
        .expand((m) => m.versionGroupDetails.map((detail) => PokemonMove(
              name: m.move.name,
              levelLearnedAt: detail.levelLearnedAt,
              learnMethod: detail.moveLearnMethod.name,
              versionGroup: detail.versionGroup.name,
            )))
        .toList();

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
      stats: stats,
      baseExperience: rawPokemon.baseExperience,
      isDefault: rawPokemon.isDefault,
      order: rawPokemon.order,
      locationAreaEncounters: rawPokemon.locationAreaEncounters,
      cryLegacy: rawPokemon.cries.legacy,
      forms: rawPokemon.forms.map((f) => PokemonForm(name: f.name, url: f.url)).toList(),
      gameIndices: rawPokemon.gameIndices.map((gi) => gi.version.name).toList(),
      speciesName: rawPokemon.species.name,
      speciesUrl: rawPokemon.species.url,
      spriteBackDefault: rawPokemon.sprites.backDefault,
      spriteFrontShiny: rawPokemon.sprites.frontShiny,
      spriteBackShiny: rawPokemon.sprites.backShiny,
      officialArtworkDefault: rawPokemon.sprites.other?.officialArtwork.frontDefault,
      officialArtworkShiny: rawPokemon.sprites.other?.officialArtwork.frontShiny,
      abilities: abilities,
      heldItems: heldItems,
      moves: moves,
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(String url) async {
    try {
      final json = await _remoteDataSource.getFormDetailsJson(url);
      final id = json['id'] as int;
      final name = json['name'] as String;
      
      final typesJson = json['types'] as List<dynamic>;
      final type1 = _getTypeFromUrl(typesJson.first['type']['url'] as String);
      final type2 = typesJson.length > 1
          ? _getTypeFromUrl(typesJson[1]['type']['url'] as String)
          : null;

      final typeImage1 = '$_kBasePath$type1.png';
      final typeImage2 = type2 != null ? '$_kBasePath$type2.png' : '';

      final spritesJson = json['sprites'] as Map<String, dynamic>;
      final spriteDefault = spritesJson['front_default'] as String;
      final spriteShiny = spritesJson['front_shiny'] as String;

      final artworkDefault =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
      final artworkShiny =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';

      return right(PokemonFormDetails(
        name: name,
        type1: type1,
        type2: type2,
        typeImage1: typeImage1,
        typeImage2: typeImage2,
        spriteDefault: spriteDefault,
        spriteShiny: spriteShiny,
        artworkDefault: artworkDefault,
        artworkShiny: artworkShiny,
      ));
    } catch (_) {
      return left(BadRequestFailure());
    }
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(String url) async {
    try {
      final rawList = await _remoteDataSource.getEncountersJson(url);
      final encounters = rawList.map((encounterMap) {
        final map = encounterMap as Map<String, dynamic>;
        final locationArea = map['location_area'] as Map<String, dynamic>;
        final rawLocationName = locationArea['name'] as String;
        
        final versionDetails = map['version_details'] as List<dynamic>;
        final versions = versionDetails
            .map((detail) => (detail as Map<String, dynamic>)['version']['name'] as String)
            .toList();

        String formatLocationName(String rawName) {
          return rawName
              .replaceAll('-', ' ')
              .split(' ')
              .map((word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '')
              .join(' ');
        }

        return PokemonEncounter(
          locationAreaName: formatLocationName(rawLocationName),
          rawLocationAreaName: rawLocationName,
          versions: versions,
        );
      }).toList();
      return right(encounters);
    } catch (_) {
      return left(BadRequestFailure());
    }
  }

  String _getTypeFromUrl(String typeUrl) {
    final lastSlashIndex = typeUrl.lastIndexOf('/');
    final trimmed = typeUrl.substring(0, lastSlashIndex);
    final previousSlashIndex = trimmed.lastIndexOf('/');
    return trimmed.substring(previousSlashIndex + 1);
  }
}

