import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

/// Form-name suffix marking the vestigial "???". Such forms have
/// no type sprite and are excluded from the exposed form list.
const _kUnknownFormSuffix = '-unknown';

typedef _Json = Map<String, dynamic>;

/// Builds the official-artwork URL for the Pokémon with the given [id],
/// returning the shiny variant when [shiny] is true.
String _officialArtworkUrl(int id, {bool shiny = false}) =>
    PokeApiUrlHelper.officialArtworkUrl(id, shiny: shiny);

@LazySingleton(as: IPokemonRepository, env: [Environment.prod])
class PokemonRepositoryImpl implements IPokemonRepository {
  PokemonRepositoryImpl(this._cache);

  final PokeApiCache _cache;

  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) {
    // `rightOrCrash` would throw a `PokemonFailure` out of this non-async
    // method, before `_fetch` can map it, so the caller would see an
    // exception instead of a `Left`. Validate first and return the failure.
    return name.value.fold(
      (failure) => Future.value(left(failure)),
      (canonical) => _fetch<_Json, Pokemon>(
        PokeApiUrlHelper.pokemonUrl(canonical),
        (json, isStale) => _toPokemon(RawPokemon.fromJson(json), isStale),
      ),
    );
  }

  Pokemon _toPokemon(RawPokemon rawPokemon, bool isStale) {
    if (rawPokemon.types.isEmpty) {
      throw FormatException(
        'Pokemon "${rawPokemon.name}" has no types specified.',
      );
    }

    final type1 = _typeFromUrl(rawPokemon.types.first.type.url);
    final type2 = rawPokemon.types.length > 1
        ? _typeFromUrl(rawPokemon.types[1].type.url)
        : null;

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
        .map((a) => PokemonAbility(name: a.ability.name, isHidden: a.isHidden))
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

    final rawSprites = rawPokemon.sprites;
    final artwork = rawSprites.other?.officialArtwork;
    final home = rawSprites.other?.home;
    final sprites = PokemonSprites(
      frontDefault: rawSprites.frontDefault,
      backDefault: rawSprites.backDefault,
      frontShiny: rawSprites.frontShiny,
      backShiny: rawSprites.backShiny,
      frontFemale: rawSprites.frontFemale,
      backFemale: rawSprites.backFemale,
      frontShinyFemale: rawSprites.frontShinyFemale,
      backShinyFemale: rawSprites.backShinyFemale,
      artworkDefault: artwork?.frontDefault,
      artworkShiny: artwork?.frontShiny,
      homeDefault: home?.frontDefault,
      homeFemale: home?.frontFemale,
      homeShiny: home?.frontShiny,
      homeShinyFemale: home?.frontShinyFemale,
    );

    return Pokemon(
      id: rawPokemon.id,
      name: rawPokemon.name,
      sprite: SpriteGalleryHelper.resolvePrimarySprite(
        artworkDefault: sprites.artworkDefault,
        frontDefault: sprites.frontDefault,
        frontShiny: sprites.frontShiny,
        backDefault: sprites.backDefault,
      ),
      weight: rawPokemon.weight,
      height: rawPokemon.height,
      type1: type1,
      type2: type2,
      cry: rawPokemon.cries.latest,
      stats: stats,
      baseExperience: rawPokemon.baseExperience,
      isDefault: rawPokemon.isDefault,
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
      gameIndices: rawPokemon.gameIndices.map((gi) => gi.version.name).toList(),
      speciesName: rawPokemon.species.name,
      speciesUrl: rawPokemon.species.url,
      sprites: sprites,
      abilities: abilities,
      heldItems: heldItems,
      moves: moves,
      isStale: isStale,
    );
  }

  @override
  Future<Either<PokemonFailure, PokemonFormDetails>> getFormDetails(
    String url,
  ) {
    return _fetch<_Json, PokemonFormDetails>(url, (json, _) {
      final raw = RawFormDetails.fromJson(json);
      if (raw.types.isEmpty) {
        throw FormatException('Form "${raw.name}" has no types specified.');
      }

      final type1 = _typeFromUrl(raw.types.first.type.url);
      final type2 = raw.types.length > 1
          ? _typeFromUrl(raw.types[1].type.url)
          : null;
      final artworkDefault = _officialArtworkUrl(raw.id);
      final artworkShiny = _officialArtworkUrl(raw.id, shiny: true);
      return PokemonFormDetails(
        name: raw.name,
        type1: type1,
        type2: type2,
        spriteDefault: raw.sprites.frontDefault ?? artworkDefault,
        spriteShiny: raw.sprites.frontShiny ?? artworkShiny,
        artworkDefault: artworkDefault,
        artworkShiny: artworkShiny,
      );
    });
  }

  @override
  Future<Either<PokemonFailure, List<PokemonEncounter>>> getEncounters(
    String url,
  ) {
    return _fetch<List<dynamic>, List<PokemonEncounter>>(url, (json, _) {
      return json.map((item) {
        final encounter = RawEncounter.fromJson(item as _Json);
        return PokemonEncounter(
          rawLocationAreaName: encounter.locationArea.name,
          versions: encounter.versionDetails
              .map((d) => d.version.name)
              .toList(),
        );
      }).toList();
    });
  }

  @override
  Future<Either<PokemonFailure, List<PokemonIndexEntry>>> getPokemonIndex({
    bool forceRefresh = false,
  }) {
    return _fetch<_Json, List<PokemonIndexEntry>>(
      PokeApiUrlHelper.pokemonIndexUrl(),
      forceRefresh: forceRefresh,
      (json, _) {
        final entries = <PokemonIndexEntry>[];
        for (final raw in json['results'] as List<dynamic>) {
          final map = raw as _Json;
          final name = map['name'] as String? ?? '';
          final url = map['url'] as String? ?? '';
          final id = PokeApiUrlHelper.extractId(url);
          if (id > 0 && name.isNotEmpty) {
            entries.add(PokemonIndexEntry(id: id, name: name, detailUrl: url));
          }
        }
        return PokemonFormClassifier.enrichEntries(entries);
      },
    );
  }

  @override
  Future<Either<PokemonFailure, Set<int>>> getPokemonIdsForType(
    PokemonType type,
  ) {
    return _fetch<_Json, Set<int>>(PokeApiUrlHelper.typeUrl(type.apiName), (
      json,
      _,
    ) {
      final ids = <int>{};
      for (final item in json['pokemon'] as List<dynamic>? ?? const []) {
        final pokemonMap = (item as _Json)['pokemon'] as _Json?;
        if (pokemonMap == null) continue;
        final id = PokeApiUrlHelper.extractId(
          pokemonMap['url'] as String? ?? '',
        );
        if (id > 0) ids.add(id);
      }
      return ids;
    });
  }

  @override
  Future<Either<PokemonFailure, MoveDetail>> getMoveDetail(String name) {
    return _fetch<_Json, MoveDetail>(PokeApiUrlHelper.moveUrl(name), (json, _) {
      final raw = RawMoveDetail.fromJson(json);
      final flavorTexts = <String, String>{};
      for (final entry in raw.flavorTextEntries) {
        // Just take the first flavor text we encounter for a language
        // (sometimes there are multiple for different game versions).
        flavorTexts.putIfAbsent(entry.language.name, () => entry.flavorText);
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
  }

  @override
  Future<Either<PokemonFailure, PokemonSpecies>> getPokemonSpecies(String url) {
    return _fetch<_Json, PokemonSpecies>(url, (json, _) {
      final raw = RawPokemonSpecies.fromJson(json);
      return PokemonSpecies(
        id: raw.id,
        name: raw.name,
        flavorTexts: raw.flavorTextEntries
            .map(
              (entry) => PokemonSpeciesFlavorText(
                text: TextNormalizer.cleanPokeApiText(entry.flavorText),
                language: entry.language.name,
                version: entry.version?.name ?? '',
              ),
            )
            .toList(),
        genera: {for (final g in raw.genera) g.language.name: g.genus},
        generation: raw.generation?.name,
        habitat: raw.habitat?.name,
        captureRate: raw.captureRate,
        baseHappiness: raw.baseHappiness,
        evolutionChainUrl: raw.evolutionChain?.url,
      );
    });
  }

  @override
  Future<Either<PokemonFailure, EvolutionChain>> getEvolutionChain(String url) {
    return _fetch<_Json, EvolutionChain>(url, (json, _) {
      final raw = RawEvolutionChain.fromJson(json);
      return EvolutionChain(id: raw.id, root: _toEvolutionNode(raw.chain));
    });
  }

  EvolutionNode _toEvolutionNode(RawChainLink link) {
    final id = PokeApiUrlHelper.extractId(link.species.url);
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
      spriteUrl: _officialArtworkUrl(id),
      triggers: triggers,
      evolvesTo: link.evolvesTo.map(_toEvolutionNode).toList(),
    );
  }

  @override
  Future<Either<PokemonFailure, AbilityDetail>> getAbilityDetail(String name) {
    return _fetch<_Json, AbilityDetail>(PokeApiUrlHelper.abilityUrl(name), (
      json,
      _,
    ) {
      final raw = RawAbilityDetail.fromJson(json);
      final flavorTexts = <String, String>{};
      for (final entry in raw.flavorTextEntries) {
        flavorTexts.putIfAbsent(
          entry.language.name,
          () => TextNormalizer.cleanPokeApiText(entry.flavorText),
        );
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
  }

  @override
  Future<Either<PokemonFailure, Unit>> clearCache() async {
    try {
      await _cache.clear();
      return right(unit);
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<PokemonFailure, int>> getCacheSize() async {
    try {
      return right(await _cache.size());
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  /// Loads the JSON at [url] through the cache and maps it with [toEntity].
  Future<Either<PokemonFailure, T>> _fetch<J, T>(
    String url,
    T Function(J json, bool isStale) toEntity, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _cache.get<J>(url, forceRefresh: forceRefresh);
      return right(toEntity(response.data, response.isStale));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  /// Resolves the [PokemonType] referenced by a PokeAPI type [typeUrl], or
  /// null when the URL points to a type outside the known set.
  PokemonType? _typeFromUrl(String typeUrl) =>
      PokemonType.fromId(PokeApiUrlHelper.extractId(typeUrl));

  /// Translates any error from the transport, cache or parsing into a
  /// [PokemonFailure].
  PokemonFailure _toFailure(Object error) {
    switch (error) {
      case ApiException(isConnectionError: true):
        return const NetworkUnavailableFailure();
      case ApiException(isTimeout: true):
        return const RequestTimeoutFailure();
      case ApiException(statusCode: 404):
        return const PokemonNotFoundFailure();
      case ApiException(statusCode: 401):
        return const UnauthorizedFailure();
      case ApiException(statusCode: 400):
        return const BadRequestFailure();
      case ApiException(statusCode: 429):
        return const RateLimitedFailure();
      case ApiException(:final int statusCode)
          when statusCode >= 500 && statusCode < 600:
        return ServerFailure(statusCode);
      case ApiException(:final message):
        return UnexpectedFailure(message);
      case SocketException():
        return const NetworkUnavailableFailure();
      case FormatException() ||
          TypeError() ||
          StateError() ||
          EmptyResponseException():
        return InvalidResponseFailure(error.toString());
      case HiveError(:final message):
        return StorageFailure(message);
      default:
        return UnexpectedFailure(error.toString());
    }
  }
}
