import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

const _kSpritesRoot =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/';

/// Form-name suffix marking the vestigial "???" type variant. Such forms have
/// no type sprite and are excluded from the exposed form list.
const _kUnknownFormSuffix = '-unknown';

/// Builds the type-icon sprite URL for the given [type], or an empty string
/// when [type] is null — unknown/unsupported types have no sprite in this set.
String _typeSpriteUrl(PokemonType? type) => type == null
    ? ''
    : '${_kSpritesRoot}types/generation-viii/sword-shield/${type.id}.png';

/// Builds the official-artwork URL for the Pokémon with the given [id],
/// returning the shiny variant when [shiny] is true.
String _officialArtworkUrl(int id, {bool shiny = false}) =>
    '${_kSpritesRoot}pokemon/other/official-artwork/${shiny ? 'shiny/' : ''}$id.png';

@LazySingleton(as: IPokemonRepository, env: [Environment.prod])
class PokemonRepositoryImpl implements IPokemonRepository {
  PokemonRepositoryImpl(this._remoteDataSource);

  final IPokemonRemoteDataSource _remoteDataSource;

  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) async {
    try {
      final result = await _remoteDataSource.getPokemon(name);
      return result.map(_toDomain);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Pokemon _toDomain(RawPokemon rawPokemon) {
    final type1 = _typeFromUrl(rawPokemon.types.first.type.url);
    final type2 = rawPokemon.types.length > 1
        ? _typeFromUrl(rawPokemon.types[1].type.url)
        : null;

    final typeImage1 = _typeSpriteUrl(type1);
    final typeImage2 = _typeSpriteUrl(type2);

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
          .where((f) => !f.name.endsWith(_kUnknownFormSuffix))
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
      final result = await _remoteDataSource.getFormDetails(url);
      return result.flatMap((raw) {
        final type1 = _typeFromUrl(raw.types.first.type.url);
        final type2 =
            raw.types.length > 1 ? _typeFromUrl(raw.types[1].type.url) : null;
        final typeImage1 = _typeSpriteUrl(type1);
        final typeImage2 = _typeSpriteUrl(type2);
        final artworkDefault = _officialArtworkUrl(raw.id);
        final artworkShiny = _officialArtworkUrl(raw.id, shiny: true);
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
      });
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
      String url) async {
    try {
      final result = await _remoteDataSource.getEncounters(url);
      return result.map((rawList) => rawList.map((encounter) {
            final rawLocationName = encounter.locationArea.name;
            final versions =
                encounter.versionDetails.map((d) => d.version.name).toList();
            return PokemonEncounter(
              locationAreaName: rawLocationName.toDisplayCase(),
              rawLocationAreaName: rawLocationName,
              versions: versions,
            );
          }).toList());
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  /// Resolves the [PokemonType] referenced by a PokeAPI type [typeUrl], or
  /// null when the URL points to a type outside the known set.
  PokemonType? _typeFromUrl(String typeUrl) =>
      _typeFromId(_getTypeFromUrl(typeUrl));

  /// Maps a raw numeric type id (extracted from a type URL) to its
  /// [PokemonType], or null when the id is outside the known set.
  PokemonType? _typeFromId(String rawId) =>
      PokemonType.fromId(int.tryParse(rawId) ?? -1);

  String _getTypeFromUrl(String typeUrl) {
    final lastSlashIndex = typeUrl.lastIndexOf('/');
    final trimmed = typeUrl.substring(0, lastSlashIndex);
    final previousSlashIndex = trimmed.lastIndexOf('/');
    return trimmed.substring(previousSlashIndex + 1);
  }
}
