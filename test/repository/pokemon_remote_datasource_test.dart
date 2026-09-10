import 'dart:io';

import 'package:dartz/dartz.dart';
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
  });

  late _MockDataRepository dataRepository;
  late PokemonRemoteDataSource dataSource;

  setUp(() {
    dataRepository = _MockDataRepository();
    dataSource = PokemonRemoteDataSource(dataRepository: dataRepository);
  });

  void stubFetchThrow(Object error) {
    when(
      () => dataRepository.fetchData(
        any(),
        strategy: any(named: 'strategy'),
        maxAge: any(named: 'maxAge'),
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
}
