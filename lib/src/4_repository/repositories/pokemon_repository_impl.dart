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
      forms: rawPokemon.forms
          .map((f) => PokemonForm(name: f.name, url: f.url))
          .toList(),
      gameIndices: rawPokemon.gameIndices.map((gi) => gi.version.name).toList(),
      speciesName: rawPokemon.species.name,
      speciesUrl: rawPokemon.species.url,
      spriteBackDefault: rawPokemon.sprites.backDefault,
      spriteFrontShiny: rawPokemon.sprites.frontShiny,
      spriteBackShiny: rawPokemon.sprites.backShiny,
      officialArtworkDefault:
          rawPokemon.sprites.other?.officialArtwork.frontDefault,
      officialArtworkShiny:
          rawPokemon.sprites.other?.officialArtwork.frontShiny,
      abilities: abilities,
      heldItems: heldItems,
      moves: moves,
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(
      String url) async {
    try {
      final raw = await _remoteDataSource.getFormDetails(url);

      final type1 = _getTypeFromUrl(raw.types.first.type.url);
      final type2 =
          raw.types.length > 1 ? _getTypeFromUrl(raw.types[1].type.url) : null;

      final typeImage1 = '$_kBasePath$type1.png';
      final typeImage2 = type2 != null ? '$_kBasePath$type2.png' : '';

      final artworkDefault =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${raw.id}.png';
      final artworkShiny =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/${raw.id}.png';

      return right(PokemonFormDetails(
        name: raw.name,
        type1: type1,
        type2: type2,
        typeImage1: typeImage1,
        typeImage2: typeImage2,
        spriteDefault: raw.sprites.frontDefault,
        spriteShiny: raw.sprites.frontShiny,
        artworkDefault: artworkDefault,
        artworkShiny: artworkShiny,
      ));
    } catch (_) {
      return left(BadRequestFailure());
    }
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
      String url) async {
    try {
      final rawList = await _remoteDataSource.getEncounters(url);
      final encounters = rawList.map((encounter) {
        final rawLocationName = encounter.locationArea.name;
        final versions =
            encounter.versionDetails.map((d) => d.version.name).toList();

        return PokemonEncounter(
          locationAreaName: rawLocationName.toDisplayCase(),
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
