import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/implementations/pokemon_remote_datasource.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/raw_pokemon.dart';
import 'package:pokefinder/src/4_repository/repositories/data_repository.dart';
import 'package:pokefinder/src/4_repository/repositories/fetch_strategy.dart';

class _MockDataRepository extends Mock implements DataRepository {}

PokemonFailure _leftOf(Either<PokemonFailure, RawPokemon> either) =>
    either.fold((l) => l, (_) => throw StateError('expected left'));

void main() {
  setUpAll(() {
    registerFallbackValue(FetchStrategy.cacheFirst);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(CancelToken());
  });

  late _MockDataRepository dataRepository;
  late PokemonRemoteDataSource dataSource;

  setUp(() {
    dataRepository = _MockDataRepository();
    dataSource = PokemonRemoteDataSource(dataRepository: dataRepository);
  });

  void stubFetchThrow(Object error) {
    when(
      () => dataRepository.fetchData<Map<String, dynamic>>(
        any(),
        strategy: any(named: 'strategy'),
        maxAge: any(named: 'maxAge'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenThrow(error);
  }

  group('PokemonRemoteDataSource error mapping', () {
    test('maps ApiException 404 to PokemonNotFoundFailure', () async {
      stubFetchThrow(ApiException(statusCode: 404, message: 'Not found'));
      final result = await dataSource.getPokemon(PokemonName('unknown'));
      expect(_leftOf(result), isA<PokemonNotFoundFailure>());
    });

    test('maps ApiException 401 to UnauthorizedFailure', () async {
      stubFetchThrow(ApiException(statusCode: 401, message: 'no'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<UnauthorizedFailure>());
    });

    test('maps ApiException 400 to BadRequestFailure', () async {
      stubFetchThrow(ApiException(statusCode: 400, message: 'bad'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<BadRequestFailure>());
    });

    test('maps ApiException 429 to RateLimitedFailure', () async {
      stubFetchThrow(ApiException(statusCode: 429, message: 'rate limit'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<RateLimitedFailure>());
    });

    test('maps ApiException 500 to ServerFailure', () async {
      stubFetchThrow(ApiException(statusCode: 500, message: 'boom'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      final failure = _leftOf(result);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test(
      'maps ApiException with isConnectionError to NetworkUnavailableFailure',
      () async {
        stubFetchThrow(
          ApiException(message: 'connect error', isConnectionError: true),
        );
        final result = await dataSource.getPokemon(PokemonName('pikachu'));
        expect(_leftOf(result), isA<NetworkUnavailableFailure>());
      },
    );

    test(
      'maps ApiException with isConnectionTimeout to RequestTimeoutFailure',
      () async {
        stubFetchThrow(
          ApiException(message: 'timeout', isConnectionTimeout: true),
        );
        final result = await dataSource.getPokemon(PokemonName('pikachu'));
        expect(_leftOf(result), isA<RequestTimeoutFailure>());
      },
    );

    test('maps SocketException to NetworkUnavailableFailure', () async {
      stubFetchThrow(const SocketException('Failed host lookup'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<NetworkUnavailableFailure>());
    });

    test('maps FormatException to InvalidResponseFailure', () async {
      stubFetchThrow(const FormatException('corrupted JSON'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<InvalidResponseFailure>());
    });

    test('maps TypeError to InvalidResponseFailure', () async {
      stubFetchThrow(TypeError());
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<InvalidResponseFailure>());
    });

    test(
      'maps ApiException with isCancelled to RequestCancelledFailure',
      () async {
        stubFetchThrow(ApiException(message: 'cancelled', isCancelled: true));
        final result = await dataSource.getPokemon(PokemonName('pikachu'));
        expect(_leftOf(result), isA<RequestCancelledFailure>());
      },
    );

    test('maps HiveError to StorageFailure', () async {
      stubFetchThrow(HiveError('Box not found'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<StorageFailure>());
    });

    test('maps non-ApiException errors to UnexpectedFailure', () async {
      stubFetchThrow(Exception('general error'));
      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(_leftOf(result), isA<UnexpectedFailure>());
    });
  });

  group('PokemonRemoteDataSource success and cache', () {
    test('propagates isStale from DataResponse metadata', () async {
      final sampleJson = {
        'id': 25,
        'name': 'pikachu',
        'weight': 60,
        'height': 4,
        'base_experience': 112,
        'is_default': true,
        'order': 35,
        'location_area_encounters':
            'https://pokeapi.co/api/v2/pokemon/25/encounters',
        'types': [
          {
            'slot': 1,
            'type': {
              'name': 'electric',
              'url': 'https://pokeapi.co/api/v2/type/13/',
            },
          },
        ],
        'abilities': [
          {
            'ability': {
              'name': 'static',
              'url': 'https://pokeapi.co/api/v2/ability/9/',
            },
            'is_hidden': false,
            'slot': 1,
          },
        ],
        'stats': [
          {
            'base_stat': 35,
            'effort': 0,
            'stat': {'name': 'hp', 'url': ''},
          },
          {
            'base_stat': 55,
            'effort': 0,
            'stat': {'name': 'attack', 'url': ''},
          },
          {
            'base_stat': 40,
            'effort': 0,
            'stat': {'name': 'defense', 'url': ''},
          },
          {
            'base_stat': 50,
            'effort': 0,
            'stat': {'name': 'special-attack', 'url': ''},
          },
          {
            'base_stat': 50,
            'effort': 0,
            'stat': {'name': 'special-defense', 'url': ''},
          },
          {
            'base_stat': 90,
            'effort': 2,
            'stat': {'name': 'speed', 'url': ''},
          },
        ],
        'sprites': {'front_default': 'https://example.com/pika.png'},
        'forms': [
          {
            'name': 'pikachu',
            'url': 'https://pokeapi.co/api/v2/pokemon-form/25/',
          },
        ],
        'moves': <Map<String, dynamic>>[],
        'game_indices': <Map<String, dynamic>>[],
        'held_items': <Map<String, dynamic>>[],
        'cries': {'latest': '', 'legacy': ''},
        'species': {'name': 'pikachu', 'url': ''},
      };

      when(
        () => dataRepository.fetchData<Map<String, dynamic>>(
          any(),
          strategy: any(named: 'strategy'),
          maxAge: any(named: 'maxAge'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => DataResponse(
          data: sampleJson,
          metadata: CacheMetadata.cacheStale(cachedAt: DateTime(2026, 1, 1)),
        ),
      );

      final result = await dataSource.getPokemon(PokemonName('pikachu'));
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected right'),
        (pokemon) => expect(pokemon.isStale, isTrue),
      );
    });

    test('clearCache delegates to dataRepository.clearCache', () async {
      when(() => dataRepository.clearCache()).thenAnswer((_) async {});

      final result = await dataSource.clearCache();
      expect(result.isRight(), isTrue);
      verify(() => dataRepository.clearCache()).called(1);
    });
  });
}
