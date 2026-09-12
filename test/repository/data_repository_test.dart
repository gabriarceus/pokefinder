import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dio/dio.dart' show CancelToken;
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
  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  late _MockApiClient apiClient;
  late _MockLocalStorage localStorage;
  late DataRepository repository;
  late DateTime simulatedNow;

  setUp(() {
    apiClient = _MockApiClient();
    localStorage = _MockLocalStorage();
    simulatedNow = DateTime(2026, 1, 1, 12, 0, 0);
    repository = DataRepository(
      apiClient: apiClient,
      localStorage: localStorage,
      logger: _MockEnLogger(),
      clock: Clock(() => simulatedNow),
    );

    when(
      () => localStorage.write<dynamic>(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => localStorage.write<Map<String, dynamic>>(any(), any()),
    ).thenAnswer((_) async {});
    when(() => localStorage.delete(any())).thenAnswer((_) async {});
    when(() => localStorage.clear()).thenAnswer((_) async {});
  });

  void stubCacheEntry(
    Map<String, dynamic>? data, {
    DateTime? storedAt,
    int schemaVersion = 1,
  }) {
    if (data == null) {
      when(
        () => localStorage.readEntry<dynamic>(any()),
      ).thenAnswer((_) async => null);
      when(
        () => localStorage.readEntry<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => null);
    } else {
      final entry = CacheEntry<Map<String, dynamic>>(
        data: data,
        schemaVersion: schemaVersion,
        storedAt: storedAt ?? simulatedNow,
        lastAccessedAt: storedAt ?? simulatedNow,
      );
      when(
        () => localStorage.readEntry<dynamic>(any()),
      ).thenAnswer((_) async => entry);
      when(
        () => localStorage.readEntry<Map<String, dynamic>>(any()),
      ).thenAnswer((_) async => entry);
    }
  }

  group('cacheFirst', () {
    test(
      'returns the cached payload without hitting the network when fresh',
      () async {
        stubCacheEntry(_cachedPayload);

        final response = await repository.fetchData<Map<String, dynamic>>(
          _endpoint,
        );

        expect(response.data, _cachedPayload);
        expect(response.metadata.isFresh, isTrue);
        expect(response.metadata.isStale, isFalse);
        expect(response.metadata.fromCache, isTrue);
        verifyNever(() => apiClient.get(any()));
      },
    );

    test(
      'fetches from network and persists when cache entry is expired',
      () async {
        // Stored 3 hours ago, maxAge is 1 hour
        stubCacheEntry(
          _cachedPayload,
          storedAt: simulatedNow.subtract(const Duration(hours: 3)),
        );
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => _networkPayload);

        final response = await repository.fetchData<Map<String, dynamic>>(
          _endpoint,
          maxAge: const Duration(hours: 1),
        );
        await pumpEventQueue();

        expect(response.data, _networkPayload);
        expect(response.metadata.isFresh, isTrue);
        expect(response.metadata.fromCache, isFalse);
        verify(
          () => localStorage.write<Map<String, dynamic>>(
            _endpoint,
            _networkPayload,
          ),
        ).called(1);
      },
    );

    test(
      'stale-if-error: falls back to stale cache when expired and network fails',
      () async {
        stubCacheEntry(
          _cachedPayload,
          storedAt: simulatedNow.subtract(const Duration(hours: 3)),
        );
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(ApiException(statusCode: 500, message: 'Server down'));

        final response = await repository.fetchData<Map<String, dynamic>>(
          _endpoint,
          maxAge: const Duration(hours: 1),
        );

        expect(response.data, _cachedPayload);
        expect(response.metadata.isStale, isTrue);
        expect(response.metadata.isFresh, isFalse);
        expect(response.metadata.fromCache, isTrue);
      },
    );

    test(
      'rethrows cancellation exception instead of falling back to stale cache',
      () async {
        stubCacheEntry(
          _cachedPayload,
          storedAt: simulatedNow.subtract(const Duration(hours: 3)),
        );
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(ApiException(message: 'cancelled', isCancelled: true));

        await expectLater(
          repository.fetchData<Map<String, dynamic>>(
            _endpoint,
            maxAge: const Duration(hours: 1),
          ),
          throwsA(
            isA<ApiException>().having(
              (e) => e.isCancelled,
              'isCancelled',
              isTrue,
            ),
          ),
        );
      },
    );

    test(
      'falls back to the network on a miss and persists the response',
      () async {
        stubCacheEntry(null);
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => _networkPayload);

        final response = await repository.fetchData<Map<String, dynamic>>(
          _endpoint,
        );
        await pumpEventQueue();

        expect(response.data, _networkPayload);
        expect(response.metadata.fromCache, isFalse);
        verify(
          () => localStorage.write<Map<String, dynamic>>(
            _endpoint,
            _networkPayload,
          ),
        ).called(1);
      },
    );

    test(
      'a failed cache write does not affect the returned network payload',
      () async {
        stubCacheEntry(null);
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => _networkPayload);
        when(
          () => localStorage.write(any(), any()),
        ).thenAnswer((_) => Future.error(Exception('disk full')));

        final response = await repository.fetchData<Map<String, dynamic>>(
          _endpoint,
        );
        await pumpEventQueue();

        expect(response.data, _networkPayload);
      },
    );

    test('a network error on a cache miss propagates to the caller', () async {
      stubCacheEntry(null);
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(ApiException(statusCode: 404, message: 'not found'));

      await expectLater(
        repository.fetchData<Map<String, dynamic>>(_endpoint),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('networkFirst', () {
    test('returns the fresh network payload and persists to cache', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => _networkPayload);

      final response = await repository.fetchData<Map<String, dynamic>>(
        _endpoint,
        strategy: FetchStrategy.networkFirst,
      );
      await pumpEventQueue();

      expect(response.data, _networkPayload);
      expect(response.metadata.fromCache, isFalse);
      verify(
        () => localStorage.write<Map<String, dynamic>>(
          _endpoint,
          _networkPayload,
        ),
      ).called(1);
    });

    test('falls back to cache when network fails', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(Exception('offline'));
      stubCacheEntry(_cachedPayload);

      final response = await repository.fetchData<Map<String, dynamic>>(
        _endpoint,
        strategy: FetchStrategy.networkFirst,
      );

      expect(response.data, _cachedPayload);
      expect(response.metadata.fromCache, isTrue);
    });

    test('marks fallback cache as stale if past maxAge', () async {
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(Exception('offline'));
      stubCacheEntry(
        _cachedPayload,
        storedAt: simulatedNow.subtract(const Duration(days: 2)),
      );

      final response = await repository.fetchData<Map<String, dynamic>>(
        _endpoint,
        strategy: FetchStrategy.networkFirst,
        maxAge: const Duration(days: 1),
      );

      expect(response.data, _cachedPayload);
      expect(response.metadata.isStale, isTrue);
    });

    test(
      'throws DataFetchException when both network and cache fail',
      () async {
        when(
          () => apiClient.get<Map<String, dynamic>>(
            _endpoint,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(Exception('offline'));
        stubCacheEntry(null);

        await expectLater(
          repository.fetchData<Map<String, dynamic>>(
            _endpoint,
            strategy: FetchStrategy.networkFirst,
          ),
          throwsA(isA<DataFetchException>()),
        );
      },
    );
  });

  group('networkOnly', () {
    test('ignores cache and refreshes it with the response', () async {
      stubCacheEntry(_cachedPayload);
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => _networkPayload);

      final response = await repository.fetchData<Map<String, dynamic>>(
        _endpoint,
        strategy: FetchStrategy.networkOnly,
      );
      await pumpEventQueue();

      expect(response.data, _networkPayload);
      verifyNever(() => localStorage.readEntry<dynamic>(any()));
      verify(
        () => localStorage.write<Map<String, dynamic>>(
          _endpoint,
          _networkPayload,
        ),
      ).called(1);
    });
  });

  group('cache maintenance & race conditions', () {
    test('clearCache wipes local storage', () async {
      await repository.clearCache();

      verify(() => localStorage.clear()).called(1);
    });

    test('invalidate removes a single entry', () async {
      await repository.invalidate(_endpoint);

      verify(() => localStorage.delete(_endpoint)).called(1);
    });

    test('clearCache invalidates lagging in-flight network writes', () async {
      stubCacheEntry(null);
      final networkCompleter = Completer<Map<String, dynamic>>();

      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) => networkCompleter.future);

      // Start network request (epoch 0)
      final fetchFuture = repository.fetchData<Map<String, dynamic>>(_endpoint);

      // Clear cache mid-flight (epoch becomes 1)
      await repository.clearCache();

      // Lagging network response finishes
      networkCompleter.complete(_networkPayload);
      final response = await fetchFuture;
      await pumpEventQueue();

      expect(response.data, _networkPayload);
      // localStorage.write should NOT be called for the old epoch!
      verifyNever(() => localStorage.write(any(), any()));
    });

    test('clearCache during write evicts written data', () async {
      stubCacheEntry(null);
      when(
        () => apiClient.get<Map<String, dynamic>>(
          _endpoint,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => _networkPayload);

      final writeCompleter = Completer<void>();
      when(
        () => localStorage.write<Map<String, dynamic>>(any(), any()),
      ).thenAnswer((_) => writeCompleter.future);

      // Start fetch: network completes, write begins
      final fetchFuture = repository.fetchData<Map<String, dynamic>>(_endpoint);
      await pumpEventQueue();

      // clearCache is called while write is still pending
      final clearFuture = repository.clearCache();

      // Complete the pending write
      writeCompleter.complete();
      await fetchFuture;
      await clearFuture;

      // Ensure localStorage.delete was called to evict the entry
      verify(() => localStorage.delete(_endpoint)).called(1);
    });
  });
}
