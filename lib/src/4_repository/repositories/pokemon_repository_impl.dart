import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
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
  PokemonRepositoryImpl(this._cache, this._logger);

  static const _prefix = 'PokemonRepositoryImpl';

  final PokeApiCache _cache;
  final EnLogger _logger;

  /// Enriched index catalog, retained until refreshed or cleared.
  ///
  /// `/pokemon/{name}` lists only a Pokémon's own resource in `forms`, so the
  /// catalog is the only place that knows every form of a species. It is read
  /// by the Pokédex grid and by every form list, hence a single snapshot.
  List<PokemonIndexEntry>? _catalog;
  int _catalogEpoch = 0;

  @override
  Future<Either<PokemonFailure, Pokemon>> getPokemon(PokemonName name) {
    // `rightOrCrash` would throw a `PokemonFailure` out of this non-async
    // method, before `_fetch` can map it, so the caller would see an
    // exception instead of a `Left`. Validate first and return the failure.
    return name.value.fold(
      (failure) => Future.value(left(failure)),
      (canonical) => _getPokemon(canonical),
    );
  }

  Future<Either<PokemonFailure, Pokemon>> _getPokemon(String canonical) async {
    try {
      final response = await _cache.get<_Json>(
        PokeApiUrlHelper.pokemonUrl(canonical),
      );
      // Best effort: a Pokémon without alternate forms is still fully usable,
      // so a catalog miss must not fail the request.
      final catalog = await _loadCatalog();
      final raw = RawPokemon.fromJson(response.data);
      final forms = await _formsFor(raw, catalog);
      return right(_toPokemon(raw, response.isStale, forms: forms));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  /// Builds the form list of [raw] from [catalog], falling back to the
  /// resource's own `forms` array when the catalog is unavailable.
  Future<List<PokemonForm>> _formsFor(
    RawPokemon raw,
    List<PokemonIndexEntry>? catalog,
  ) async {
    final type1 = raw.types.isEmpty
        ? null
        : _typeFromUrl(raw.types.first.type.url);
    final type2 = raw.types.length > 1
        ? _typeFromUrl(raw.types[1].type.url)
        : null;

    if (catalog != null) {
      final forms = await _catalogFormsFor(raw, catalog);
      if (forms.isNotEmpty) return forms;
    }
    return _resourceFormsFor(raw, type1, type2);
  }

  /// Every catalog entry sharing the resource's species, canonical entry first.
  Future<List<PokemonForm>> _catalogFormsFor(
    RawPokemon raw,
    List<PokemonIndexEntry> catalog,
  ) async {
    var parentId = 0;
    for (final entry in catalog) {
      if (entry.name == raw.name) {
        parentId = entry.effectiveParentSpeciesId;
        break;
      }
    }
    if (parentId <= 0) return const [];

    final siblings = catalog.where(
      (entry) =>
          entry.effectiveParentSpeciesId == parentId &&
          !entry.name.endsWith(_kUnknownFormSuffix) &&
          PokemonFormClassifier.hasRealForm(entry.name) &&
          entry.formCategory != PokemonFormCategory.cosmetic,
    );
    return Future.wait(
      siblings.map((entry) async {
        if (entry.name == raw.name) {
          return PokemonForm(
            name: entry.name,
            url: entry.detailUrl,
            type1: raw.types.isEmpty
                ? null
                : _typeFromUrl(raw.types.first.type.url),
            type2: raw.types.length > 1
                ? _typeFromUrl(raw.types[1].type.url)
                : null,
          );
        }
        final result = await getFormDetails(
          PokeApiUrlHelper.pokemonUrl(entry.name),
        );
        return result.fold(
          (_) => PokemonForm(name: entry.name, url: entry.detailUrl),
          (details) => PokemonForm(
            name: entry.name,
            url: entry.detailUrl,
            type1: details.type1,
            type2: details.type2,
          ),
        );
      }),
    );
  }

  /// The `forms` array of `/pokemon/{name}`, which only ever names the
  /// Pokémon itself.
  List<PokemonForm> _resourceFormsFor(
    RawPokemon raw,
    PokemonType? baseType1,
    PokemonType? baseType2,
  ) {
    return raw.forms.where((f) => !f.name.endsWith(_kUnknownFormSuffix)).map((
      f,
    ) {
      final (formType1, formType2) = PokemonFormClassifier.resolveFormTypes(
        formName: f.name,
        baseType1: baseType1,
        baseType2: baseType2,
      );
      return PokemonForm(
        name: f.name,
        url: f.url,
        type1: formType1,
        type2: formType2,
      );
    }).toList();
  }

  Pokemon _toPokemon(
    RawPokemon rawPokemon,
    bool isStale, {
    required List<PokemonForm> forms,
  }) {
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
      gameIndices: rawPokemon.gameIndices.map((gi) => gi.version.name).toList(),
      speciesName: rawPokemon.species.name,
      speciesUrl: rawPokemon.species.url,
      sprites: sprites,
      abilities: abilities,
      heldItems: heldItems,
      moves: moves,
      forms: forms,
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
        id: raw.id,
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
  }) async {
    final memoized = _catalog;
    if (!forceRefresh && memoized != null) return right(memoized);

    var isStale = false;
    final epoch = _catalogEpoch;
    final result = await _fetch<_Json, List<PokemonIndexEntry>>(
      PokeApiUrlHelper.pokemonIndexUrl(),
      (json, stale) {
        isStale = stale;
        return _toIndexEntries(json);
      },
      forceRefresh: forceRefresh,
    );
    return result.fold((failure) => left(failure), (entries) {
      // A stale offline copy is served but not kept, so the next call
      // tries the network again.
      if (!isStale && epoch == _catalogEpoch) _catalog = entries;
      return right(entries);
    });
  }

  /// The memoized catalog, or null when it cannot be loaded.
  ///
  /// A stale cached copy counts: it is still the best form list available.
  Future<List<PokemonIndexEntry>?> _loadCatalog() async {
    final result = await getPokemonIndex();
    return result.fold((failure) {
      _logger.warning(
        'Pokédex index unavailable, forms fall back to the resource list: $failure',
        prefix: _prefix,
      );
      return null;
    }, (entries) => entries);
  }

  List<PokemonIndexEntry> _toIndexEntries(_Json json) {
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
    final url = name.startsWith('http')
        ? name
        : PokeApiUrlHelper.abilityUrl(name);
    return _fetch<_Json, AbilityDetail>(url, (json, _) {
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
    _catalog = null;
    _catalogEpoch++;
    try {
      await _cache.clear();
      return right(unit);
    } catch (error) {
      return left(_toFailure(error));
    } finally {
      _catalog = null;
      _catalogEpoch++;
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
