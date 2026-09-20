import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

/// Form-name suffix marking the vestigial "???". Such forms have
/// no type sprite and are excluded from the exposed form list.
const _kUnknownFormSuffix = '-unknown';

/// Builds the type-icon sprite URL for the given [type], or an empty string
/// when [type] is null — unknown/unsupported types have no sprite in this set.
String _typeSpriteUrl(PokemonType? type) =>
    type == null ? '' : PokeApiUrlHelper.typeSpriteUrl(type.id);

/// Builds the official-artwork URL for the Pokémon with the given [id],
/// returning the shiny variant when [shiny] is true.
String _officialArtworkUrl(int id, {bool shiny = false}) =>
    PokeApiUrlHelper.officialArtworkUrl(id, shiny: shiny);

@LazySingleton(as: IPokemonRepository, env: [Environment.prod])
class PokemonRepositoryImpl implements IPokemonRepository {
  PokemonRepositoryImpl(this._remoteDataSource);

  final IPokemonRemoteDataSource _remoteDataSource;

  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(
    PokemonName name, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getPokemon(
        name,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.flatMap(_toDomain);
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  Either<PokemonFailure, Pokemon> _toDomain(RawPokemon rawPokemon) {
    if (rawPokemon.types.isEmpty) {
      return left(
        InvalidResponseFailure(
          'Pokemon "${rawPokemon.name}" has no types specified.',
        ),
      );
    }

    final type1 = _typeFromUrl(rawPokemon.types.first.type.url);
    final type2 = rawPokemon.types.length > 1
        ? _typeFromUrl(rawPokemon.types[1].type.url)
        : null;

    final typeImage1 = _typeSpriteUrl(type1);
    final typeImage2 = _typeSpriteUrl(type2);

    final statMap = <String, int>{
      for (final s in rawPokemon.stats) s.stat.name: s.baseStat,
    };
    final stats = [
      statMap['hp'] ?? 0,
      statMap['attack'] ?? 0,
      statMap['defense'] ?? 0,
      statMap['special-attack'] ?? 0,
      statMap['special-defense'] ?? 0,
      statMap['speed'] ?? 0,
    ];

    final abilities = rawPokemon.abilities
        .map(
          (a) => PokemonAbility(
            name: a.ability.name,
            isHidden: a.isHidden,
            slot: a.slot,
          ),
        )
        .toList();

    final heldItems = rawPokemon.heldItems
        .expand(
          (item) => item.versionDetails.map(
            (detail) => PokemonHeldItem(
              name: item.item.name,
              rarity: detail.rarity,
              version: detail.version.name,
            ),
          ),
        )
        .toList();

    final moves = rawPokemon.moves
        .expand(
          (m) => m.versionGroupDetails.map(
            (detail) => PokemonMove(
              name: m.move.name,
              levelLearnedAt: detail.levelLearnedAt,
              learnMethod: detail.moveLearnMethod.name,
              versionGroup: detail.versionGroup.name,
            ),
          ),
        )
        .toList();

    final officialArtworkDefault =
        rawPokemon.sprites.other?.officialArtwork?.frontDefault;
    final officialArtworkShiny =
        rawPokemon.sprites.other?.officialArtwork?.frontShiny;
    final home = rawPokemon.sprites.other?.home;

    final sprite = SpriteGalleryHelper.resolvePrimarySprite(
      artworkDefault: officialArtworkDefault,
      frontDefault: rawPokemon.sprites.frontDefault,
      frontShiny: rawPokemon.sprites.frontShiny,
      backDefault: rawPokemon.sprites.backDefault,
    );

    return right(
      Pokemon(
        id: rawPokemon.id,
        name: rawPokemon.name,
        sprite: sprite,
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
            .map((f) {
              final (
                formType1,
                formType2,
              ) = PokemonFormClassifier.resolveFormTypes(
                formName: f.name,
                baseType1: type1,
                baseType2: type2,
              );
              return PokemonForm(
                name: f.name,
                url: f.url,
                type1: formType1,
                type2: formType2,
              );
            })
            .toList(),
        gameIndices: rawPokemon.gameIndices
            .map((gi) => gi.version.name)
            .toList(),
        speciesName: rawPokemon.species.name,
        speciesUrl: rawPokemon.species.url,
        spriteBackDefault: rawPokemon.sprites.backDefault,
        spriteFrontDefault: rawPokemon.sprites.frontDefault,
        spriteFrontShiny: rawPokemon.sprites.frontShiny,
        spriteBackShiny: rawPokemon.sprites.backShiny,
        spriteFrontFemale: rawPokemon.sprites.frontFemale,
        spriteBackFemale: rawPokemon.sprites.backFemale,
        spriteFrontShinyFemale: rawPokemon.sprites.frontShinyFemale,
        spriteBackShinyFemale: rawPokemon.sprites.backShinyFemale,
        officialArtworkDefault: officialArtworkDefault,
        officialArtworkShiny: officialArtworkShiny,
        homeDefault: home?.frontDefault,
        homeFemale: home?.frontFemale,
        homeShiny: home?.frontShiny,
        homeShinyFemale: home?.frontShinyFemale,
        abilities: abilities,
        heldItems: heldItems,
        moves: moves,
        isStale: rawPokemon.isStale,
      ),
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getFormDetails(
        url,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.flatMap((raw) {
        if (raw.types.isEmpty) {
          return left(
            InvalidResponseFailure(
              'Form "${raw.name}" has no types specified.',
            ),
          );
        }

        final type1 = _typeFromUrl(raw.types.first.type.url);
        final type2 = raw.types.length > 1
            ? _typeFromUrl(raw.types[1].type.url)
            : null;
        final typeImage1 = _typeSpriteUrl(type1);
        final typeImage2 = _typeSpriteUrl(type2);
        final artworkDefault = _officialArtworkUrl(raw.id);
        final artworkShiny = _officialArtworkUrl(raw.id, shiny: true);
        final spriteDefault = raw.sprites.frontDefault ?? artworkDefault;
        final spriteShiny = raw.sprites.frontShiny ?? artworkShiny;
        return right(
          PokemonFormDetails(
            name: raw.name,
            type1: type1,
            type2: type2,
            typeImage1: typeImage1,
            typeImage2: typeImage2,
            spriteDefault: spriteDefault,
            spriteShiny: spriteShiny,
            artworkDefault: artworkDefault,
            artworkShiny: artworkShiny,
          ),
        );
      });
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getEncounters(
        url,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.map(
        (rawList) => rawList.map((encounter) {
          final rawLocationName = encounter.locationArea.name;
          final versions = encounter.versionDetails
              .map((d) => d.version.name)
              .toList();
          return PokemonEncounter(
            locationAreaName: rawLocationName.toDisplayCase(),
            rawLocationAreaName: rawLocationName,
            versions: versions,
          );
        }).toList(),
      );
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    CancellationToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    try {
      final result = await _remoteDataSource.getPokemonIndex(
        cancelToken: _bridgeToDio(cancelToken),
        forceRefresh: forceRefresh,
      );
      return result.map(PokemonFormClassifier.enrichEntries);
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type, {
    CancellationToken? cancelToken,
  }) async {
    try {
      return await _remoteDataSource.getPokemonIdsForType(
        type,
        cancelToken: _bridgeToDio(cancelToken),
      );
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, List<String>>> getAllPokemonNames() async {
    try {
      return await _remoteDataSource.getAllPokemonNames();
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, MoveDetail>> getMoveDetail(
    String name, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getMoveDetail(
        name,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.map((raw) {
        final flavorTexts = <String, String>{};
        for (final entry in raw.flavorTextEntries) {
          // Just take the first flavor text we encounter for a language
          // (sometimes there are multiple for different game versions).
          if (!flavorTexts.containsKey(entry.language.name)) {
            flavorTexts[entry.language.name] = entry.flavorText;
          }
        }

        return MoveDetail(
          id: raw.id,
          name: raw.name,
          accuracy: raw.accuracy,
          power: raw.power,
          pp: raw.pp,
          type: _typeFromUrl(raw.type.url),
          damageClass: DamageClass.fromApiName(raw.damageClass.name),
          flavorTexts: flavorTexts,
        );
      });
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, PokemonSpecies>> getPokemonSpecies(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getPokemonSpecies(
        url,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.map((raw) {
        final flavorTexts = raw.flavorTextEntries
            .map(
              (entry) => PokemonSpeciesFlavorText(
                text: TextNormalizer.cleanPokeApiText(entry.flavorText),
                language: entry.language.name,
                version: entry.version?.name ?? '',
              ),
            )
            .toList();

        final genera = <String, String>{
          for (final g in raw.genera) g.language.name: g.genus,
        };

        return PokemonSpecies(
          id: raw.id,
          name: raw.name,
          flavorTexts: flavorTexts,
          genera: genera,
          generation: raw.generation?.name,
          habitat: raw.habitat?.name,
          captureRate: raw.captureRate,
          baseHappiness: raw.baseHappiness,
          growthRate: raw.growthRate?.name,
          genderRate: raw.genderRate,
          eggGroups: raw.eggGroups.map((e) => e.name).toList(),
          evolutionChainUrl: raw.evolutionChain?.url,
          isBaby: raw.isBaby,
          isLegendary: raw.isLegendary,
          isMythical: raw.isMythical,
        );
      });
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, EvolutionChain>> getEvolutionChain(
    String url, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getEvolutionChain(
        url,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.map((raw) {
        return EvolutionChain(id: raw.id, root: _toEvolutionNode(raw.chain));
      });
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  EvolutionNode _toEvolutionNode(RawChainLink link) {
    final id = _idFromUrl(link.species.url);
    final spriteUrl = _officialArtworkUrl(id);
    final triggers = link.evolutionDetails.map((d) {
      return EvolutionTriggerDetail(
        triggerType: EvolutionTriggerType.fromApiName(d.trigger?.name),
        minLevel: d.minLevel,
        item: d.item?.name,
        heldItem: d.heldItem?.name,
        minHappiness: d.minHappiness,
        timeOfDay: d.timeOfDay,
        location: d.location?.name,
        knownMove: d.knownMove?.name,
        knownMoveType: d.knownMoveType?.name,
        turnUpsideDown: d.turnUpsideDown,
        tradeSpecies: d.tradeSpecies?.name,
        relativePhysicalStats: d.relativePhysicalStats,
        needsRain: d.needsOverworldRain,
        gender: d.gender,
        partySpecies: d.partySpecies?.name,
        partyType: d.partyType?.name,
        minBeauty: d.minBeauty,
        minAffection: d.minAffection,
      );
    }).toList();

    return EvolutionNode(
      speciesId: id,
      speciesName: link.species.name,
      speciesUrl: link.species.url,
      spriteUrl: spriteUrl,
      triggers: triggers,
      evolvesTo: link.evolvesTo.map(_toEvolutionNode).toList(),
    );
  }

  @override
  Future<Either<PokemonFailure, AbilityDetail>> getAbilityDetail(
    String name, {
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _remoteDataSource.getAbilityDetail(
        name,
        cancelToken: _bridgeToDio(cancelToken),
      );
      return result.map((raw) {
        final flavorTexts = <String, String>{};
        for (final entry in raw.flavorTextEntries) {
          if (!flavorTexts.containsKey(entry.language.name)) {
            flavorTexts[entry.language.name] = TextNormalizer.cleanPokeApiText(
              entry.flavorText,
            );
          }
        }

        final effects = <String, String>{};
        final shortEffects = <String, String>{};
        for (final entry in raw.effectEntries) {
          effects[entry.language.name] = TextNormalizer.cleanPokeApiText(
            entry.effect,
          );
          shortEffects[entry.language.name] = TextNormalizer.cleanPokeApiText(
            entry.shortEffect,
          );
        }

        return AbilityDetail(
          id: raw.id,
          name: raw.name,
          flavorTexts: flavorTexts,
          effects: effects,
          shortEffects: shortEffects,
        );
      });
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  int _idFromUrl(String url) => PokeApiUrlHelper.extractId(url);

  PokemonFailure _mapRepoError(Object e) {
    if (e is PokemonFailure) return e;
    if (e is TypeError ||
        e is FormatException ||
        e is StateError ||
        e is EmptyResponseException) {
      return InvalidResponseFailure(e.toString());
    }
    return UnexpectedFailure(e.toString());
  }

  /// Resolves the [PokemonType] referenced by a PokeAPI type [typeUrl], or
  /// null when the URL points to a type outside the known set.
  PokemonType? _typeFromUrl(String typeUrl) =>
      PokemonType.fromId(PokeApiUrlHelper.extractId(typeUrl));

  @override
  Future<Either<PokemonFailure, Unit>> clearCache() async {
    try {
      return await _remoteDataSource.clearCache();
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }

  @override
  Future<Either<PokemonFailure, int>> getCacheSize() async {
    try {
      return await _remoteDataSource.getCacheSize();
    } catch (e) {
      return left(_mapRepoError(e));
    }
  }
}

/// Bridges a domain [CancellationToken] to Dio's [CancelToken].
///
/// Returns `null` when [token] is `null`. The returned Dio token is
/// cancelled automatically when the domain token fires.
CancelToken? _bridgeToDio(CancellationToken? token) {
  if (token == null) return null;
  final dioToken = CancelToken();
  token.onCancel(() => dioToken.cancel(token.reason));
  if (token.isCancelled) {
    dioToken.cancel(token.reason);
  }
  return dioToken;
}
