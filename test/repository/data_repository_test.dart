import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';
import 'package:pokefinder/src/4_repository/repositories/data_repository.dart';
import 'package:pokefinder/src/4_repository/repositories/fetch_strategy.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockLocalStorage extends Mock implements LocalStorage {}

class _MockEnLogger extends Mock implements EnLogger {}

const _endpoint = 'https://pokeapi.co/api/v2/pokemon/pikachu';
const _networkPayload = {'name': 'pikachu', 'source': 'network'};
const _cachedPayload = {'name': 'pikachu', 'source': 'cache'};

void main() {
  late _MockApiClient apiClient;
  late _MockLocalStorage localStorage;
  late DataRepository repository;

  setUp(() {
    apiClient = _MockApiClient();
    localStorage = _MockLocalStorage();
    repository = DataRepository(
      apiClient: apiClient,
      localStorage: localStorage,
      logger: _MockEnLogger(),
    );

    when(() => localStorage.write(any(), any())).thenAnswer((_) async {});
    when(() => localStorage.delete(any())).thenAnswer((_) async {});
    when(() => localStorage.clear()).thenAnswer((_) async {});
  });

  void stubCache(dynamic value) {
    when(
      () => localStorage.read(any(), maxAge: any(named: 'maxAge')),
    ).thenAnswer((_) async => value);
  }

  group('cacheFirst', () {
    test('returns the cached payload without hitting the network', () async {
      stubCache(_cachedPayload);

      final data = await repository.fetchData(_endpoint);

      expect(data, _cachedPayload);
      verifyNever(() => apiClient.get(any()));
    });

    test('forwards maxAge to the storage expiry check', () async {
      stubCache(_cachedPayload);

      await repository.fetchData(_endpoint, maxAge: const Duration(hours: 24));

      verify(
        () => localStorage.read(_endpoint, maxAge: const Duration(hours: 24)),
      ).called(1);
    });

    test(
      'falls back to the network on a miss and persists the response',
      () async {
        stubCache(null);
        when(
          () => apiClient.get(_endpoint),
        ).thenAnswer((_) async => _networkPayload);

        final data = await repository.fetchData(_endpoint);
        await pumpEventQueue();

        expect(data, _networkPayload);
        verify(() => localStorage.write(_endpoint, _networkPayload)).called(1);
      },
    );

    test('a failed cache write does not affect the returned payload', () async {
      stubCache(null);
      when(
        () => apiClient.get(_endpoint),
      ).thenAnswer((_) async => _networkPayload);
      when(
        () => localStorage.write(any(), any()),
      ).thenAnswer((_) => Future.error(Exception('disk full')));

      final data = await repository.fetchData(_endpoint);
      await pumpEventQueue();

      expect(data, _networkPayload);
    });

    test('a network error on a cache miss propagates to the caller', () async {
      stubCache(null);
      when(
        () => apiClient.get(_endpoint),
      ).thenThrow(ApiException(statusCode: 404, message: 'not found'));

      await expectLater(
        repository.fetchData(_endpoint),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('networkFirst', () {
    test('returns the fresh payload and awaits the cache write', () async {
      when(
        () => apiClient.get(_endpoint),
      ).thenAnswer((_) async => _networkPayload);

      final data = await repository.fetchData(
        _endpoint,
        strategy: FetchStrategy.networkFirst,
      );

      expect(data, _networkPayload);
      verify(() => localStorage.write(_endpoint, _networkPayload)).called(1);
    });

    test('falls back to the cache when the network fails', () async {
      when(() => apiClient.get(_endpoint)).thenThrow(Exception('offline'));
      when(
        () => localStorage.read(_endpoint),
      ).thenAnswer((_) async => _cachedPayload);

      final data = await repository.fetchData(
        _endpoint,
        strategy: FetchStrategy.networkFirst,
      );

      expect(data, _cachedPayload);
    });

    test(
      'throws DataFetchException when both network and cache fail',
      () async {
        when(() => apiClient.get(_endpoint)).thenThrow(Exception('offline'));
        when(() => localStorage.read(_endpoint)).thenAnswer((_) async => null);

        await expectLater(
          repository.fetchData(_endpoint, strategy: FetchStrategy.networkFirst),
          throwsA(isA<DataFetchException>()),
        );
      },
    );
  });

  group('networkOnly', () {
    test('ignores the cache and refreshes it with the response', () async {
      stubCache(_cachedPayload);
      when(
        () => apiClient.get(_endpoint),
      ).thenAnswer((_) async => _networkPayload);

      final data = await repository.fetchData(
        _endpoint,
        strategy: FetchStrategy.networkOnly,
      );

      expect(data, _networkPayload);
      verifyNever(() => localStorage.read(any(), maxAge: any(named: 'maxAge')));
      verify(() => localStorage.write(_endpoint, _networkPayload)).called(1);
    });
  });

  group('cache maintenance', () {
    test('clearCache wipes local storage', () async {
      await repository.clearCache();

      verify(() => localStorage.clear()).called(1);
    });

    test('invalidate removes a single entry', () async {
      await repository.invalidate(_endpoint);

      verify(() => localStorage.delete(_endpoint)).called(1);
    });
  });
}
