import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/helpers/pokeapi_url_helper.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/implementations/poke_api_cache.dart';
import 'package:pokefinder/src/4_repository/repositories/pokemon_repository_impl.dart';

class _MockPokeApiCache extends Mock implements PokeApiCache {}

/// PokeAPI type resource URL for the type with the given [id].
String typeUrl(int id) => 'https://pokeapi.co/api/v2/type/$id/';

/// Minimal PokeAPI `/pokemon/{name}` payload, overridable per section.
Map<String, dynamic> rawPokemonJson({
  String name = 'venusaur',
  List<Map<String, dynamic>>? types,
  List<Map<String, dynamic>>? abilities,
  List<Map<String, dynamic>>? forms,
  List<Map<String, dynamic>>? moves,
  List<Map<String, dynamic>>? heldItems,
  Map<String, dynamic>? sprites,
}) {
  return {
    'id': 3,
    'name': name,
    'weight': 1000,
    'height': 20,
    'base_experience': 263,
    'is_default': true,
    'order': 5,
    'location_area_encounters':
        'https://pokeapi.co/api/v2/pokemon/3/encounters',
    'types':
        types ??
        [
          {
            'type': {'url': typeUrl(12)},
          },
        ],
    'abilities':
        abilities ??
        [
          {
            'ability': {'name': 'overgrow'},
            'is_hidden': false,
            'slot': 1,
          },
        ],
    'stats': [
      {
        'base_stat': 80,
        'effort': 0,
        'stat': {'name': 'hp', 'url': ''},
      },
      {
        'base_stat': 82,
        'effort': 0,
        'stat': {'name': 'attack', 'url': ''},
      },
    ],
    'cries': {'latest': 'latest.ogg', 'legacy': 'legacy.ogg'},
    'sprites':
        sprites ??
        {
          'front_default': 'front.png',
          'back_default': null,
          'front_shiny': 'front-shiny.png',
          'back_shiny': null,
          'other': {
            'official-artwork': {
              'front_default': 'artwork.png',
              'front_shiny': 'artwork-shiny.png',
            },
          },
        },
    'forms':
        forms ??
        [
          {'name': 'venusaur', 'url': 'form/3/'},
        ],
    'game_indices': [
      {
        'game_index': 3,
        'version': {'name': 'red', 'url': ''},
      },
    ],
    'held_items': heldItems ?? const [],
    'moves': moves ?? const [],
    'species': {'name': 'venusaur', 'url': 'species/3/'},
  };
}

void main() {
  late _MockPokeApiCache cache;
  late PokemonRepositoryImpl repository;

  setUp(() {
    cache = _MockPokeApiCache();
    repository = PokemonRepositoryImpl(cache, EnLogger());
  });

  /// Serves [json] for every JSON-object cache read.
  void stubJsonPayload(
    Map<String, dynamic> json, {
    bool forceRefresh = false,
    bool isStale = false,
  }) {
    when(
      () => cache.get<Map<String, dynamic>>(any(), forceRefresh: forceRefresh),
    ).thenAnswer((_) async => (data: json, isStale: isStale));
  }

  /// Serves [json] only for the JSON-object cache read targeting [url].
  void stubJsonPayloadAt(
    String url,
    Map<String, dynamic> json, {
    bool forceRefresh = false,
    bool isStale = false,
  }) {
    when(
      () => cache.get<Map<String, dynamic>>(url, forceRefresh: forceRefresh),
    ).thenAnswer((_) async => (data: json, isStale: isStale));
  }

  /// Serves [json] for the cache read of [url] returning a bare JSON array.
  void stubJsonListPayload(
    String url,
    List<dynamic> json, {
    bool forceRefresh = false,
    bool isStale = false,
  }) {
    when(
      () => cache.get<List<dynamic>>(url, forceRefresh: forceRefresh),
    ).thenAnswer((_) async => (data: json, isStale: isStale));
  }

  /// Unwraps the [Left] of an endpoint result, failing the test on a [Right].
  PokemonFailure leftOf<T>(Either<PokemonFailure, T> result) =>
      result.fold((failure) => failure, (_) => fail('expected a left'));

  /// Unwraps the [Right] of an endpoint result, failing the test on a [Left].
  T rightOf<T>(Either<PokemonFailure, T> result) =>
      result.getOrElse(() => throw StateError('expected a right'));

  /// Minimal `/pokemon` index payload.
  Map<String, dynamic> indexJson(List<Map<String, dynamic>> results) => {
    'count': results.length,
    'next': null,
    'previous': null,
    'results': results,
  };

  /// Serves [json] from the cache and maps it into a [Pokemon].
  Future<Pokemon> mapPokemon(
    Map<String, dynamic> json, {
    bool isStale = false,
  }) async {
    stubJsonPayload(json, isStale: isStale);
    return rightOf(await repository.getPokemon(PokemonName('venusaur')));
  }

  group('getPokemon type mapping', () {
    test('resolves both types from their resource URLs', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          types: [
            {
              'type': {'url': typeUrl(12)},
            },
            {
              'type': {'url': typeUrl(4)},
            },
          ],
        ),
      );

      expect(pokemon.type1, PokemonType.grass);
      expect(pokemon.type2, PokemonType.poison);
    });

    test('leaves the second type unset for a single-type Pokémon', () async {
      final pokemon = await mapPokemon(rawPokemonJson());

      expect(pokemon.type1, PokemonType.grass);
      expect(pokemon.type2, isNull);
    });

    test(
      'returns InvalidResponseFailure when types collection is empty',
      () async {
        stubJsonPayload(rawPokemonJson(types: const []));

        final result = await repository.getPokemon(PokemonName('venusaur'));

        expect(result.isLeft(), isTrue);
        final failure = leftOf(result);
        expect(failure, isA<InvalidResponseFailure>());
        expect(failure.message, contains('has no types specified'));
      },
    );

    test('an unknown type id maps to no type', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          types: [
            {
              'type': {'url': typeUrl(9999)},
            },
          ],
        ),
      );

      expect(pokemon.type1, isNull);
      expect(pokemon.type2, isNull);
    });
  });

  group('getPokemon ability mapping', () {
    test(
      'fills the ability slots in order and blanks the missing ones',
      () async {
        final pokemon = await mapPokemon(
          rawPokemonJson(
            abilities: [
              {
                'ability': {'name': 'overgrow'},
                'is_hidden': false,
                'slot': 1,
              },
              {
                'ability': {'name': 'chlorophyll'},
                'is_hidden': true,
                'slot': 3,
              },
            ],
          ),
        );

        expect(pokemon.abilities, const [
          PokemonAbility(name: 'overgrow', isHidden: false),
          PokemonAbility(name: 'chlorophyll', isHidden: true),
        ]);
      },
    );
  });

  group('getPokemon form mapping', () {
    test('drops the vestigial "-unknown" form', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          forms: [
            {'name': 'arceus', 'url': 'form/493/'},
            {'name': 'arceus-unknown', 'url': 'form/10141/'},
            {'name': 'arceus-fire', 'url': 'form/10142/'},
          ],
        ),
      );

      expect(pokemon.forms.map((f) => f.name), ['arceus', 'arceus-fire']);
    });
  });

  group('getPokemon nested list flattening', () {
    test('expands one move entry per version group detail', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          moves: [
            {
              'move': {'name': 'tackle', 'url': ''},
              'version_group_details': [
                {
                  'level_learned_at': 1,
                  'move_learn_method': {'name': 'level-up', 'url': ''},
                  'version_group': {'name': 'red-blue', 'url': ''},
                },
                {
                  'level_learned_at': 3,
                  'move_learn_method': {'name': 'level-up', 'url': ''},
                  'version_group': {'name': 'sword-shield', 'url': ''},
                },
              ],
            },
          ],
        ),
      );

      expect(pokemon.moves, const [
        PokemonMove(
          name: 'tackle',
          levelLearnedAt: 1,
          learnMethod: 'level-up',
          versionGroup: 'red-blue',
        ),
        PokemonMove(
          name: 'tackle',
          levelLearnedAt: 3,
          learnMethod: 'level-up',
          versionGroup: 'sword-shield',
        ),
      ]);
    });

    test('expands one held item per version detail', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          heldItems: [
            {
              'item': {'name': 'oran-berry', 'url': ''},
              'version_details': [
                {
                  'rarity': 5,
                  'version': {'name': 'ruby', 'url': ''},
                },
                {
                  'rarity': 50,
                  'version': {'name': 'emerald', 'url': ''},
                },
              ],
            },
          ],
        ),
      );

      expect(pokemon.heldItems, const [
        PokemonHeldItem(name: 'oran-berry', rarity: 5, version: 'ruby'),
        PokemonHeldItem(name: 'oran-berry', rarity: 50, version: 'emerald'),
      ]);
    });
  });

  group('getPokemon sprite mapping', () {
    test(
      'leaves the official artwork unset when the payload omits it',
      () async {
        final pokemon = await mapPokemon(
          rawPokemonJson(
            sprites: {
              'front_default': 'front.png',
              'back_default': null,
              'front_shiny': null,
              'back_shiny': null,
              'other': null,
            },
          ),
        );

        expect(pokemon.sprite, 'front.png');
        expect(pokemon.sprites.artworkDefault, isNull);
        expect(pokemon.sprites.artworkShiny, isNull);
      },
    );

    test(
      'maps the full sprite payload including female and home variants',
      () async {
        final pokemon = await mapPokemon(
          rawPokemonJson(
            sprites: {
              'front_default': 'front.png',
              'back_default': 'back.png',
              'front_shiny': 'front-shiny.png',
              'back_shiny': 'back-shiny.png',
              'front_female': 'front-female.png',
              'back_female': 'back-female.png',
              'front_shiny_female': 'front-shiny-female.png',
              'back_shiny_female': 'back-shiny-female.png',
              'other': {
                'official-artwork': {
                  'front_default': 'artwork.png',
                  'front_shiny': 'artwork-shiny.png',
                },
                'home': {
                  'front_default': 'home.png',
                  'front_female': 'home-female.png',
                  'front_shiny': 'home-shiny.png',
                  'front_shiny_female': 'home-shiny-female.png',
                },
              },
            },
          ),
        );

        expect(pokemon.sprite, 'artwork.png');
        expect(pokemon.sprites.frontDefault, 'front.png');
        expect(pokemon.sprites.backDefault, 'back.png');
        expect(pokemon.sprites.frontShiny, 'front-shiny.png');
        expect(pokemon.sprites.backShiny, 'back-shiny.png');
        expect(pokemon.sprites.frontFemale, 'front-female.png');
        expect(pokemon.sprites.backFemale, 'back-female.png');
        expect(pokemon.sprites.frontShinyFemale, 'front-shiny-female.png');
        expect(pokemon.sprites.backShinyFemale, 'back-shiny-female.png');
        expect(pokemon.sprites.artworkDefault, 'artwork.png');
        expect(pokemon.sprites.artworkShiny, 'artwork-shiny.png');
        expect(pokemon.sprites.homeDefault, 'home.png');
        expect(pokemon.sprites.homeFemale, 'home-female.png');
        expect(pokemon.sprites.homeShiny, 'home-shiny.png');
        expect(pokemon.sprites.homeShinyFemale, 'home-shiny-female.png');
      },
    );

    test(
      'leaves female and home variants null for a partial payload',
      () async {
        final pokemon = await mapPokemon(
          rawPokemonJson(
            sprites: {
              'front_default': 'front.png',
              'back_default': null,
              'front_shiny': null,
              'back_shiny': null,
              'front_female': null,
              'back_female': null,
              'front_shiny_female': null,
              'back_shiny_female': null,
              'other': {
                'official-artwork': {
                  'front_default': 'artwork.png',
                  'front_shiny': null,
                },
                'home': null,
              },
            },
          ),
        );

        expect(pokemon.sprite, 'artwork.png');
        expect(pokemon.sprites.frontFemale, isNull);
        expect(pokemon.sprites.backFemale, isNull);
        expect(pokemon.sprites.frontShinyFemale, isNull);
        expect(pokemon.sprites.backShinyFemale, isNull);
        expect(pokemon.sprites.homeDefault, isNull);
        expect(pokemon.sprites.homeFemale, isNull);
        expect(pokemon.sprites.homeShiny, isNull);
        expect(pokemon.sprites.homeShinyFemale, isNull);
      },
    );

    test('empty sprite payload yields an empty primary sprite', () async {
      final pokemon = await mapPokemon(
        rawPokemonJson(
          sprites: {
            'front_default': null,
            'back_default': null,
            'front_shiny': null,
            'back_shiny': null,
            'front_female': null,
            'back_female': null,
            'front_shiny_female': null,
            'back_shiny_female': null,
            'other': null,
          },
        ),
      );

      expect(pokemon.sprite, isEmpty);
      expect(pokemon.sprites.artworkDefault, isNull);
      expect(pokemon.sprites.homeDefault, isNull);
    });
  });

  group('getPokemon staleness', () {
    test('propagates the cache staleness flag onto the entity', () async {
      final pokemon = await mapPokemon(rawPokemonJson(), isStale: true);

      expect(pokemon.isStale, isTrue);
    });

    test('a fresh cache read is not marked stale', () async {
      final pokemon = await mapPokemon(rawPokemonJson());

      expect(pokemon.isStale, isFalse);
    });
  });

  group('getPokemon failures', () {
    test('a transport error is mapped to its PokemonFailure', () async {
      when(
        () => cache.get<Map<String, dynamic>>(any(), forceRefresh: false),
      ).thenThrow(ApiException(message: 'unauthorized', statusCode: 401));

      final result = await repository.getPokemon(PokemonName('venusaur'));

      expect(
        result,
        left<PokemonFailure, Pokemon>(const UnauthorizedFailure()),
      );
    });

    test(
      'a malformed payload becomes an InvalidResponseFailure instead of throwing',
      () async {
        stubJsonPayload(rawPokemonJson(types: const []));

        final result = await repository.getPokemon(PokemonName('venusaur'));

        expect(result.isLeft(), isTrue);
        expect(leftOf(result), isA<InvalidResponseFailure>());
      },
    );

    test(
      'an invalid Pokémon name fails before the cache is consulted',
      () async {
        final result = await repository.getPokemon(PokemonName('   '));

        expect(leftOf(result), isA<BadRequestFailure>());
        verifyNever(
          () => cache.get<Map<String, dynamic>>(any(), forceRefresh: false),
        );
      },
    );
  });

  group('error mapping', () {
    /// Runs [getPokemon] with the cache throwing [error] and returns the
    /// resulting failure.
    Future<PokemonFailure> failureFor(Object error) {
      when(
        () => cache.get<Map<String, dynamic>>(any(), forceRefresh: false),
      ).thenThrow(error);
      return repository
          .getPokemon(PokemonName('venusaur'))
          .then(leftOf<Pokemon>);
    }

    test('a connection error becomes NetworkUnavailableFailure', () async {
      expect(
        await failureFor(
          ApiException(message: 'offline', isConnectionError: true),
        ),
        isA<NetworkUnavailableFailure>(),
      );
    });

    test('a timeout becomes RequestTimeoutFailure', () async {
      expect(
        await failureFor(ApiException(message: 'slow', isReceiveTimeout: true)),
        isA<RequestTimeoutFailure>(),
      );
    });

    test('a 404 becomes PokemonNotFoundFailure', () async {
      expect(
        await failureFor(ApiException(message: 'missing', statusCode: 404)),
        isA<PokemonNotFoundFailure>(),
      );
    });

    test('a 400 becomes BadRequestFailure', () async {
      expect(
        await failureFor(ApiException(message: 'bad', statusCode: 400)),
        isA<BadRequestFailure>(),
      );
    });

    test('a 401 becomes UnauthorizedFailure', () async {
      expect(
        await failureFor(ApiException(message: 'nope', statusCode: 401)),
        isA<UnauthorizedFailure>(),
      );
    });

    test('a 429 becomes RateLimitedFailure', () async {
      expect(
        await failureFor(ApiException(message: 'slow down', statusCode: 429)),
        isA<RateLimitedFailure>(),
      );
    });

    test('a 5xx becomes ServerFailure carrying the status code', () async {
      final failure = await failureFor(
        ApiException(message: 'boom', statusCode: 503),
      );

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 503);
    });

    test('any other status code becomes UnexpectedFailure', () async {
      expect(
        await failureFor(ApiException(message: 'teapot', statusCode: 418)),
        isA<UnexpectedFailure>(),
      );
    });

    test('a socket exception becomes NetworkUnavailableFailure', () async {
      expect(
        await failureFor(const SocketException('no host')),
        isA<NetworkUnavailableFailure>(),
      );
    });

    test('an empty body becomes InvalidResponseFailure', () async {
      expect(
        await failureFor(EmptyResponseException('endpoint')),
        isA<InvalidResponseFailure>(),
      );
    });

    test('a parse error becomes InvalidResponseFailure', () async {
      expect(
        await failureFor(const FormatException('malformed data')),
        isA<InvalidResponseFailure>(),
      );
    });

    test('a storage error becomes StorageFailure', () async {
      expect(
        await failureFor(HiveError('box corrupted')),
        isA<StorageFailure>(),
      );
    });

    test('an unrecognized error becomes UnexpectedFailure', () async {
      expect(
        await failureFor(Exception('Unexpected crash')),
        isA<UnexpectedFailure>(),
      );
    });
  });

  group('getFormDetails', () {
    test(
      'derives type sprites and official artwork from the form id',
      () async {
        stubJsonPayloadAt('form/10033/', {
          'id': 10033,
          'name': 'venusaur-mega',
          'types': [
            {
              'type': {'url': typeUrl(12)},
            },
            {
              'type': {'url': typeUrl(4)},
            },
          ],
          'sprites': {
            'front_default': 'mega.png',
            'front_shiny': 'mega-shiny.png',
          },
        });

        final details = rightOf(await repository.getFormDetails('form/10033/'));

        expect(details.name, 'venusaur-mega');
        expect(details.type1, PokemonType.grass);
        expect(details.type2, PokemonType.poison);
        expect(details.spriteDefault, 'mega.png');
        expect(details.spriteShiny, 'mega-shiny.png');
        expect(details.artworkDefault, endsWith('official-artwork/10033.png'));
        expect(details.artworkShiny, endsWith('shiny/10033.png'));
      },
    );

    test(
      'returns InvalidResponseFailure when form types collection is empty',
      () async {
        stubJsonPayloadAt('form/10033/', {
          'id': 10033,
          'name': 'venusaur-mega',
          'types': <Map<String, dynamic>>[],
          'sprites': {'front_default': 'mega.png'},
        });

        final result = await repository.getFormDetails('form/10033/');

        expect(result.isLeft(), isTrue);
        final failure = leftOf(result);
        expect(failure, isA<InvalidResponseFailure>());
        expect(failure.message, contains('has no types specified'));
      },
    );
  });

  group('getEncounters', () {
    test('exposes the raw location name and the version list', () async {
      stubJsonListPayload('encounters', [
        {
          'location_area': {'name': 'viridian-forest-area', 'url': ''},
          'version_details': [
            {
              'version': {'name': 'red', 'url': ''},
            },
            {
              'version': {'name': 'blue', 'url': ''},
            },
          ],
        },
      ]);

      final encounters = rightOf(await repository.getEncounters('encounters'));

      expect(encounters, const [
        PokemonEncounter(
          rawLocationAreaName: 'viridian-forest-area',
          versions: ['red', 'blue'],
        ),
      ]);
    });
  });

  group('getMoveDetail', () {
    test('keeps the first flavor text per language', () async {
      stubJsonPayloadAt(PokeApiUrlHelper.moveUrl('tackle'), {
        'id': 33,
        'name': 'tackle',
        'accuracy': 100,
        'power': 40,
        'pp': 35,
        'type': {'name': 'normal', 'url': typeUrl(1)},
        'damage_class': {'name': 'physical', 'url': ''},
        'flavor_text_entries': [
          {
            'flavor_text': 'First english entry',
            'language': {'name': 'en', 'url': ''},
          },
          {
            'flavor_text': 'Later english entry',
            'language': {'name': 'en', 'url': ''},
          },
          {
            'flavor_text': 'Voce italiana',
            'language': {'name': 'it', 'url': ''},
          },
        ],
      });

      final detail = rightOf(await repository.getMoveDetail('tackle'));

      expect(
        detail,
        const MoveDetail(
          id: 33,
          name: 'tackle',
          accuracy: 100,
          power: 40,
          pp: 35,
          type: PokemonType.normal,
          damageClass: DamageClass.physical,
          flavorTexts: {'en': 'First english entry', 'it': 'Voce italiana'},
        ),
      );
    });

    test('an unrecognized damage class maps to null', () async {
      stubJsonPayloadAt(PokeApiUrlHelper.moveUrl('mystery'), {
        'id': 1,
        'name': 'mystery',
        'type': {'name': 'normal', 'url': typeUrl(1)},
        'damage_class': {'name': 'quantum', 'url': ''},
      });

      final detail = rightOf(await repository.getMoveDetail('mystery'));

      expect(detail.damageClass, isNull);
    });
  });

  group('getPokemonSpecies', () {
    test('maps the species payload and normalizes its flavor texts', () async {
      stubJsonPayloadAt('species/3/', {
        'id': 3,
        'name': 'venusaur',
        'generation': {'name': 'generation-i', 'url': ''},
        'habitat': {'name': 'grassland', 'url': ''},
        'capture_rate': 45,
        'base_happiness': 50,
        'is_legendary': false,
        'is_mythical': false,
        'flavor_text_entries': [
          {
            'flavor_text':
                'The plant blooms when it is absorbing\nsolar energy.',
            'language': {'name': 'en', 'url': ''},
            'version': {'name': 'red', 'url': ''},
          },
          {
            'flavor_text': 'Voce italiana',
            'language': {'name': 'it', 'url': ''},
            'version': null,
          },
        ],
        'genera': [
          {
            'genus': 'Seed Pokémon',
            'language': {'name': 'en', 'url': ''},
          },
        ],
        'evolution_chain': {'url': 'chain/1/'},
      });

      final species = rightOf(await repository.getPokemonSpecies('species/3/'));

      expect(species.id, 3);
      expect(species.name, 'venusaur');
      expect(species.generation, 'generation-i');
      expect(species.habitat, 'grassland');
      expect(species.captureRate, 45);
      expect(species.baseHappiness, 50);
      expect(species.evolutionChainUrl, 'chain/1/');
      expect(species.genera, {'en': 'Seed Pokémon'});
      expect(species.flavorTexts.map((f) => (f.language, f.text)), [
        ('en', 'The plant blooms when it is absorbing solar energy.'),
        ('it', 'Voce italiana'),
      ]);
      // The null `version` of the italian entry degrades to an empty string.
      expect(species.flavorTexts.last.version, '');
    });
  });

  group('getPokemon stat mapping by name', () {
    test(
      'maps stats by explicit API name even if array is shuffled or reversed',
      () async {
        final shuffledStats = [
          {
            'base_stat': 99,
            'effort': 0,
            'stat': {'name': 'speed', 'url': ''},
          },
          {
            'base_stat': 88,
            'effort': 0,
            'stat': {'name': 'special-defense', 'url': ''},
          },
          {
            'base_stat': 77,
            'effort': 0,
            'stat': {'name': 'special-attack', 'url': ''},
          },
          {
            'base_stat': 66,
            'effort': 0,
            'stat': {'name': 'defense', 'url': ''},
          },
          {
            'base_stat': 55,
            'effort': 0,
            'stat': {'name': 'attack', 'url': ''},
          },
          {
            'base_stat': 44,
            'effort': 0,
            'stat': {'name': 'hp', 'url': ''},
          },
        ];

        final json = rawPokemonJson()..['stats'] = shuffledStats;
        final pokemon = await mapPokemon(json);

        // Order should always be: [hp, attack, defense, special-attack, special-defense, speed]
        expect(pokemon.stats, [44, 55, 66, 77, 88, 99]);
      },
    );
  });

  group('getPokemon sprite fallback order', () {
    test('prefers official artwork over front_default', () async {
      final json = rawPokemonJson(
        sprites: {
          'front_default': 'front.png',
          'other': {
            'official-artwork': {'front_default': 'artwork.png'},
          },
        },
      );
      final pokemon = await mapPokemon(json);
      expect(pokemon.sprite, 'artwork.png');
    });

    test(
      'falls back to front_default when official artwork is missing',
      () async {
        final json = rawPokemonJson(
          sprites: {'front_default': 'front.png', 'other': null},
        );
        final pokemon = await mapPokemon(json);
        expect(pokemon.sprite, 'front.png');
      },
    );

    test(
      'falls back to front_shiny when both artwork and front_default are missing',
      () async {
        final json = rawPokemonJson(
          sprites: {
            'front_default': null,
            'front_shiny': 'shiny.png',
            'other': null,
          },
        );
        final pokemon = await mapPokemon(json);
        expect(pokemon.sprite, 'shiny.png');
      },
    );
  });

  group('cache maintenance', () {
    test('clearCache delegates to the cache and reports success', () async {
      when(() => cache.clear()).thenAnswer((_) async {});

      final result = await repository.clearCache();

      expect(result, right(unit));
      verify(() => cache.clear()).called(1);
    });

    test('clearCache maps a storage error to a failure', () async {
      when(() => cache.clear()).thenThrow(HiveError('box corrupted'));

      final result = await repository.clearCache();

      expect(leftOf(result), isA<StorageFailure>());
    });

    test('getCacheSize returns the byte size reported by the cache', () async {
      when(() => cache.size()).thenAnswer((_) async => 4096);

      final result = await repository.getCacheSize();

      expect(result, right(4096));
      verify(() => cache.size()).called(1);
    });

    test('getCacheSize maps a storage error to a failure', () async {
      when(() => cache.size()).thenThrow(HiveError('box corrupted'));

      final result = await repository.getCacheSize();

      expect(leftOf(result), isA<StorageFailure>());
    });
  });

  group('getPokemonIndex', () {
    test(
      'requests the index with forceRefresh and maps each result to an entry',
      () async {
        stubJsonPayloadAt(
          PokeApiUrlHelper.pokemonIndexUrl(),
          indexJson([
            {
              'name': 'bulbasaur',
              'url': 'https://pokeapi.co/api/v2/pokemon/1/',
            },
            {'name': 'ivysaur', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
          ]),
          forceRefresh: true,
        );

        final result = await repository.getPokemonIndex(forceRefresh: true);

        final entries = rightOf(result);
        expect(entries.map((e) => (e.id, e.name, e.detailUrl)), [
          (1, 'bulbasaur', 'https://pokeapi.co/api/v2/pokemon/1/'),
          (2, 'ivysaur', 'https://pokeapi.co/api/v2/pokemon/2/'),
        ]);
        verify(
          () => cache.get<Map<String, dynamic>>(
            PokeApiUrlHelper.pokemonIndexUrl(),
            forceRefresh: true,
          ),
        ).called(1);
      },
    );

    test('drops results without a resolvable id or a name', () async {
      stubJsonPayloadAt(
        PokeApiUrlHelper.pokemonIndexUrl(),
        indexJson([
          {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
          {'name': '', 'url': 'https://pokeapi.co/api/v2/pokemon/2/'},
          {'name': 'ivysaur', 'url': 'not-a-url'},
        ]),
      );

      final entries = rightOf(await repository.getPokemonIndex());

      expect(entries.map((e) => e.name), ['bulbasaur']);
    });

    test(
      'a fresh index is kept in memory, a stale one is read again',
      () async {
        final index = indexJson([
          {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
        ]);
        Future<void> readTwice({required bool isStale}) async {
          stubJsonPayloadAt(
            PokeApiUrlHelper.pokemonIndexUrl(),
            index,
            isStale: isStale,
          );
          await repository.getPokemonIndex();
          await repository.getPokemonIndex();
        }

        await readTwice(isStale: true);
        verify(
          () => cache.get<Map<String, dynamic>>(
            PokeApiUrlHelper.pokemonIndexUrl(),
            forceRefresh: false,
          ),
        ).called(2);

        await readTwice(isStale: false);
        verify(
          () => cache.get<Map<String, dynamic>>(
            PokeApiUrlHelper.pokemonIndexUrl(),
            forceRefresh: false,
          ),
        ).called(1);
      },
    );

    test(
      'returns UnexpectedFailure when the cache throws unexpectedly',
      () async {
        when(
          () => cache.get<Map<String, dynamic>>(any(), forceRefresh: false),
        ).thenThrow(Exception('Unexpected crash'));

        final result = await repository.getPokemonIndex();

        expect(leftOf(result), isA<UnexpectedFailure>());
      },
    );
  });

  group('getPokemonIdsForType', () {
    test('collects the ids of the pokemon listed for the type', () async {
      stubJsonPayloadAt(PokeApiUrlHelper.typeUrl('fire'), {
        'pokemon': [
          {
            'pokemon': {
              'name': 'charmander',
              'url': 'https://pokeapi.co/api/v2/pokemon/4/',
            },
          },
          {
            'pokemon': {
              'name': 'charmeleon',
              'url': 'https://pokeapi.co/api/v2/pokemon/5/',
            },
          },
          {
            'pokemon': {'name': 'broken', 'url': 'not-a-url'},
          },
        ],
      });

      final result = await repository.getPokemonIdsForType(PokemonType.fire);

      expect(rightOf(result), {4, 5});
      verify(
        () => cache.get<Map<String, dynamic>>(
          PokeApiUrlHelper.typeUrl('fire'),
          forceRefresh: false,
        ),
      ).called(1);
    });

    test(
      'returns UnexpectedFailure when the cache throws unexpectedly',
      () async {
        when(
          () => cache.get<Map<String, dynamic>>(any(), forceRefresh: false),
        ).thenThrow(Exception('Unexpected crash'));

        final result = await repository.getPokemonIdsForType(PokemonType.fire);

        expect(leftOf(result), isA<UnexpectedFailure>());
      },
    );
  });

  group('getEvolutionChain', () {
    test(
      'maps raw evolution chain with compound trigger details to domain entity',
      () async {
        stubJsonPayloadAt('chain/352/', {
          'id': 352,
          'chain': {
            'species': {
              'name': 'inkay',
              'url': 'https://pokeapi.co/api/v2/pokemon-species/686/',
            },
            'evolution_details': <Map<String, dynamic>>[],
            'evolves_to': [
              {
                'species': {
                  'name': 'malamar',
                  'url': 'https://pokeapi.co/api/v2/pokemon-species/687/',
                },
                'evolution_details': [
                  {
                    'trigger': {'name': 'level-up', 'url': ''},
                    'min_level': 30,
                    'turn_upside_down': true,
                    'needs_overworld_rain': false,
                    'relative_physical_stats': null,
                    'gender': 1,
                    'party_species': {'name': 'remoraid', 'url': ''},
                    'party_type': {'name': 'dark', 'url': ''},
                    'trade_species': {'name': 'shelmet', 'url': ''},
                  },
                ],
                'evolves_to': <Map<String, dynamic>>[],
              },
            ],
          },
        });

        final result = await repository.getEvolutionChain('chain/352/');

        expect(result.isRight(), isTrue);
        final chain = rightOf(result);
        expect(chain.id, 352);
        expect(chain.root.speciesName, 'inkay');
        expect(chain.root.speciesId, 686);
        expect(chain.root.evolvesTo.length, 1);

        final malamarNode = chain.root.evolvesTo.first;
        expect(malamarNode.speciesName, 'malamar');
        expect(malamarNode.speciesId, 687);
        expect(malamarNode.triggers.length, 1);

        final trigger = malamarNode.triggers.first;
        expect(trigger.triggerType, EvolutionTriggerType.levelUp);
        expect(trigger.minLevel, 30);
        expect(trigger.turnUpsideDown, isTrue);
        expect(trigger.needsRain, isFalse);
        expect(trigger.gender, 1);
        expect(trigger.partySpecies, 'remoraid');
        expect(trigger.partyType, 'dark');
        expect(trigger.tradeSpecies, 'shelmet');
      },
    );
  });

  group('getPokemon alternate forms', () {
    /// Index entry for the `charizard` family, as the live catalog ships it.
    Map<String, dynamic> charizardIndex() => indexJson([
      {'name': 'charizard', 'url': 'https://pokeapi.co/api/v2/pokemon/6/'},
      {
        'name': 'charizard-gmax',
        'url': 'https://pokeapi.co/api/v2/pokemon/10037/',
      },
      {
        'name': 'charizard-mega-x',
        'url': 'https://pokeapi.co/api/v2/pokemon/10034/',
      },
      {
        'name': 'charizard-mega-y',
        'url': 'https://pokeapi.co/api/v2/pokemon/10035/',
      },
      {'name': 'pikachu', 'url': 'https://pokeapi.co/api/v2/pokemon/25/'},
      {
        'name': 'pikachu-cosplay',
        'url': 'https://pokeapi.co/api/v2/pokemon/10082/',
      },
    ]);

    setUp(() {
      stubJsonPayloadAt(PokeApiUrlHelper.pokemonIndexUrl(), charizardIndex());
    });

    test(
      'lists every catalog form of the species, not just the resource',
      () async {
        stubJsonPayloadAt(
          PokeApiUrlHelper.pokemonUrl('charizard'),
          rawPokemonJson(name: 'charizard'),
        );

        final pokemon = rightOf(
          await repository.getPokemon(PokemonName('charizard')),
        );

        expect(
          pokemon.forms.map((f) => f.name).toList(),
          containsAll([
            'charizard',
            'charizard-gmax',
            'charizard-mega-x',
            'charizard-mega-y',
          ]),
        );
        // Another species' forms and cosmetic costumes stay out.
        expect(pokemon.forms.map((f) => f.name), isNot(contains('pikachu')));
        expect(
          pokemon.forms.map((f) => f.name),
          isNot(contains('pikachu-cosplay')),
        );
      },
    );

    test('a numeric id lists the same forms as the name', () async {
      stubJsonPayloadAt(
        PokeApiUrlHelper.pokemonUrl('6'),
        rawPokemonJson(name: 'charizard'),
      );

      final pokemon = rightOf(await repository.getPokemon(PokemonName('6')));

      expect(
        pokemon.forms.map((f) => f.name),
        containsAll(['charizard', 'charizard-mega-x', 'charizard-mega-y']),
      );
    });

    test('resolves the types of a form whose species type changes', () async {
      stubJsonPayloadAt(
        PokeApiUrlHelper.pokemonUrl('charizard'),
        rawPokemonJson(
          name: 'charizard',
          types: [
            {
              'type': {'url': typeUrl(6)},
            },
            {
              'type': {'url': typeUrl(10)},
            },
          ],
        ),
      );

      final pokemon = rightOf(
        await repository.getPokemon(PokemonName('charizard')),
      );

      final megaX = pokemon.forms.firstWhere(
        (f) => f.name == 'charizard-mega-x',
      );
      expect(megaX.type1, PokemonType.fire);
      expect(megaX.type2, PokemonType.dragon);
      expect(megaX.url, 'https://pokeapi.co/api/v2/pokemon/10034/');
    });

    test(
      'falls back to the resource list when the catalog is unavailable',
      () async {
        when(
          () => cache.get<Map<String, dynamic>>(
            PokeApiUrlHelper.pokemonIndexUrl(),
            forceRefresh: false,
          ),
        ).thenThrow(const SocketException('offline'));
        stubJsonPayloadAt(
          PokeApiUrlHelper.pokemonUrl('venusaur'),
          rawPokemonJson(),
        );

        final pokemon = rightOf(
          await repository.getPokemon(PokemonName('venusaur')),
        );

        expect(pokemon.forms.map((f) => f.name), ['venusaur']);
      },
    );
  });
}
