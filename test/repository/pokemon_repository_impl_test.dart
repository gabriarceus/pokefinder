import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/i_pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_encounter/raw_encounter.dart';
import 'package:pokefinder/src/4_repository/models/raw_form_details/raw_form_details.dart';
import 'package:pokefinder/src/4_repository/models/raw_move_detail/raw_move_detail.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';
import 'package:pokefinder/src/4_repository/repositories/pokemon_repository_impl.dart';

class _MockRemoteDataSource extends Mock implements IPokemonRemoteDataSource {}

/// PokeAPI type resource URL for the type with the given [id].
String typeUrl(int id) => 'https://pokeapi.co/api/v2/type/$id/';

/// Minimal PokeAPI `/pokemon/{name}` payload, overridable per section.
Map<String, dynamic> rawPokemonJson({
  List<Map<String, dynamic>>? types,
  List<Map<String, dynamic>>? abilities,
  List<Map<String, dynamic>>? forms,
  List<Map<String, dynamic>>? moves,
  List<Map<String, dynamic>>? heldItems,
  Map<String, dynamic>? sprites,
}) {
  return {
    'id': 3,
    'name': 'venusaur',
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
  setUpAll(() => registerFallbackValue(PokemonName('placeholder')));

  late _MockRemoteDataSource dataSource;
  late PokemonRepositoryImpl repository;

  setUp(() {
    dataSource = _MockRemoteDataSource();
    repository = PokemonRepositoryImpl(dataSource);
  });

  /// Maps [json] through the repository and returns the resulting entity.
  Future<Pokemon> mapPokemon(Map<String, dynamic> json) async {
    when(
      () => dataSource.getPokemon(any()),
    ).thenAnswer((_) async => right(RawPokemon.fromJson(json)));
    final result = await repository.getPokemon(PokemonName('venusaur'));
    return result.getOrElse(() => throw StateError('expected a right'));
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
      expect(pokemon.typeImage1, endsWith('/12.png'));
      expect(pokemon.typeImage2, endsWith('/4.png'));
    });

    test('leaves the second type unset for a single-type Pokémon', () async {
      final pokemon = await mapPokemon(rawPokemonJson());

      expect(pokemon.type1, PokemonType.grass);
      expect(pokemon.type2, isNull);
      expect(pokemon.typeImage2, isEmpty);
    });

    test(
      'returns InvalidResponseFailure when types collection is empty',
      () async {
        when(() => dataSource.getPokemon(any())).thenAnswer(
          (_) async =>
              right(RawPokemon.fromJson(rawPokemonJson(types: const []))),
        );

        final result = await repository.getPokemon(PokemonName('venusaur'));

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<InvalidResponseFailure>());
          expect(failure.message, contains('has no types specified'));
        }, (_) => fail('expected left'));
      },
    );

    test('an unknown type id maps to no type and no sprite', () async {
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
      expect(pokemon.typeImage1, isEmpty);
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
          PokemonAbility(name: 'overgrow', isHidden: false, slot: 1),
          PokemonAbility(name: 'chlorophyll', isHidden: true, slot: 3),
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
        expect(pokemon.officialArtworkDefault, isNull);
        expect(pokemon.officialArtworkShiny, isNull);
      },
    );
  });

  group('getPokemon failures', () {
    test('a datasource failure is propagated unchanged', () async {
      when(
        () => dataSource.getPokemon(any()),
      ).thenAnswer((_) async => left(const UnauthorizedFailure()));

      final result = await repository.getPokemon(PokemonName('venusaur'));

      expect(
        result,
        left<PokemonFailure, Pokemon>(const UnauthorizedFailure()),
      );
    });

    test(
      'a malformed payload becomes an InvalidResponseFailure instead of throwing',
      () async {
        final json = rawPokemonJson(types: const []);
        when(
          () => dataSource.getPokemon(any()),
        ).thenAnswer((_) async => right(RawPokemon.fromJson(json)));

        final result = await repository.getPokemon(PokemonName('venusaur'));

        expect(result.isLeft(), isTrue);
        expect(
          result.fold((l) => l, (_) => null),
          isA<InvalidResponseFailure>(),
        );
      },
    );
  });

  group('getFormDetails', () {
    test(
      'derives type sprites and official artwork from the form id',
      () async {
        when(() => dataSource.getFormDetails(any())).thenAnswer(
          (_) async => right(
            RawFormDetails.fromJson({
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
            }),
          ),
        );

        final result = await repository.getFormDetails('form/10033/');
        final details = result.getOrElse(
          () => throw StateError('expected a right'),
        );

        expect(details.name, 'venusaur-mega');
        expect(details.type1, PokemonType.grass);
        expect(details.type2, PokemonType.poison);
        expect(details.typeImage1, endsWith('/12.png'));
        expect(details.spriteDefault, 'mega.png');
        expect(details.artworkDefault, endsWith('official-artwork/10033.png'));
        expect(details.artworkShiny, endsWith('shiny/10033.png'));
      },
    );

    test(
      'returns InvalidResponseFailure when form types collection is empty',
      () async {
        when(() => dataSource.getFormDetails(any())).thenAnswer(
          (_) async => right(
            RawFormDetails.fromJson({
              'id': 10033,
              'name': 'venusaur-mega',
              'types': <Map<String, dynamic>>[],
              'sprites': {'front_default': 'mega.png'},
            }),
          ),
        );

        final result = await repository.getFormDetails('form/10033/');

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<InvalidResponseFailure>());
          expect(failure.message, contains('has no types specified'));
        }, (_) => fail('expected left'));
      },
    );
  });

  group('getEncounters', () {
    test('exposes both the raw and the display-cased location name', () async {
      when(() => dataSource.getEncounters(any())).thenAnswer(
        (_) async => right([
          RawEncounter.fromJson({
            'location_area': {'name': 'viridian-forest-area', 'url': ''},
            'version_details': [
              {
                'version': {'name': 'red', 'url': ''},
              },
              {
                'version': {'name': 'blue', 'url': ''},
              },
            ],
          }),
        ]),
      );

      final result = await repository.getEncounters('encounters');
      final encounters = result.getOrElse(
        () => throw StateError('expected a right'),
      );

      expect(encounters, const [
        PokemonEncounter(
          locationAreaName: 'Viridian Forest Area',
          rawLocationAreaName: 'viridian-forest-area',
          versions: ['red', 'blue'],
        ),
      ]);
    });
  });

  group('getMoveDetail', () {
    test('keeps the first flavor text per language', () async {
      when(() => dataSource.getMoveDetail(any())).thenAnswer(
        (_) async => right(
          RawMoveDetail.fromJson({
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
          }),
        ),
      );

      final result = await repository.getMoveDetail('tackle');
      final detail = result.getOrElse(
        () => throw StateError('expected a right'),
      );

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
      when(() => dataSource.getMoveDetail(any())).thenAnswer(
        (_) async => right(
          RawMoveDetail.fromJson({
            'id': 1,
            'name': 'mystery',
            'type': {'name': 'normal', 'url': typeUrl(1)},
            'damage_class': {'name': 'quantum', 'url': ''},
          }),
        ),
      );

      final result = await repository.getMoveDetail('mystery');
      final detail = result.getOrElse(
        () => throw StateError('expected a right'),
      );

      expect(detail.damageClass, isNull);
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

  group('clearCache', () {
    test('delegates clearCache to remote data source', () async {
      when(() => dataSource.clearCache()).thenAnswer((_) async => right(unit));

      final result = await repository.clearCache();
      expect(result, right(unit));
      verify(() => dataSource.clearCache()).called(1);
    });
  });

  group('getPokemonIndex', () {
    test(
      'delegates getPokemonIndex to remote data source with cancelToken and forceRefresh',
      () async {
        const sampleEntries = [
          PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: 'url1'),
        ];
        when(
          () => dataSource.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => right(sampleEntries));

        final result = await repository.getPokemonIndex(forceRefresh: true);
        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => []), equals(sampleEntries));
        verify(
          () => dataSource.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
            forceRefresh: true,
          ),
        ).called(1);
      },
    );

    test(
      'returns UnexpectedFailure when remote data source throws unexpected error',
      () async {
        when(
          () => dataSource.getPokemonIndex(
            cancelToken: any(named: 'cancelToken'),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenThrow(Exception('Unexpected crash'));

        final result = await repository.getPokemonIndex();
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('expected left'),
        );
      },
    );
  });

  group('getPokemonIdsForType', () {
    test(
      'delegates getPokemonIdsForType to remote data source with cancelToken',
      () async {
        when(
          () => dataSource.getPokemonIdsForType(
            PokemonType.fire,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Right({4, 5, 6}));

        final result = await repository.getPokemonIdsForType(PokemonType.fire);
        expect(result, const Right({4, 5, 6}));
        verify(
          () => dataSource.getPokemonIdsForType(
            PokemonType.fire,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).called(1);
      },
    );

    test(
      'returns UnexpectedFailure when remote data source throws unexpected error',
      () async {
        when(
          () => dataSource.getPokemonIdsForType(
            PokemonType.fire,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(Exception('Unexpected crash'));

        final result = await repository.getPokemonIdsForType(PokemonType.fire);
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<UnexpectedFailure>()),
          (_) => fail('expected left'),
        );
      },
    );
  });
}
