import 'dart:async';

import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';
import 'package:pokefinder/src/4_repository/datasources/implementations/poke_api_cache.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockLocalStorage extends Mock implements LocalStorage {}

class _MockEnLogger extends Mock implements EnLogger {}

const _endpoint = 'https://pokeapi.co/api/v2/pokemon/pikachu';
const _otherEndpoint = 'https://pokeapi.co/api/v2/pokemon/ditto';
const _networkPayload = {'name': 'pikachu', 'source': 'network'};
const _cachedPayload = {'name': 'pikachu', 'source': 'cache'};

/// The fixed freshness window of [PokeApiCache]; it is a constant, so expiry
/// is driven by the injected clock rather than by a per-call parameter.
const _maxAge = Duration(hours: 24);

void main() {
  late _MockApiClient apiClient;
  late _MockLocalStorage localStorage;
  late _MockEnLogger logger;
  late PokeApiCache cache;
  late DateTime simulatedNow;

  setUp(() {
    apiClient = _MockApiClient();
    localStorage = _MockLocalStorage();
    logger = _MockEnLogger();
    simulatedNow = DateTime(2026, 1, 1, 12, 0, 0);
    cache = PokeApiCache(
      apiClient: apiClient,
      localStorage: localStorage,
      logger: logger,
      clock: Clock(() => simulatedNow),
    );

    when(
      () => localStorage.write<Map<String, dynamic>>(any(), any()),
    ).thenAnswer((_) async {});
    when(() => localStorage.clear()).thenAnswer((_) async {});
  });

  /// Makes the storage return [data] as an envelope stored at [storedAt], or
  /// report a cache miss when [data] is null.
  void stubCacheEntry(
    Map<String, dynamic>? data, {
    DateTime? storedAt,
    String url = _endpoint,
  }) {
    if (data == null) {
      when(
        () => localStorage.readEntry<Map<String, dynamic>>(url),
      ).thenAnswer((_) async => null);
      return;
    }
    final entry = CacheEntry<Map<String, dynamic>>(
      data: data,
      storedAt: storedAt ?? simulatedNow,
      lastAccessedAt: storedAt ?? simulatedNow,
    );
    when(
      () => localStorage.readEntry<Map<String, dynamic>>(url),
    ).thenAnswer((_) async => entry);
  }

  /// Stubs a network read of [url] resolving with [payload].
  void stubNetworkPayload(
    Map<String, dynamic> payload, {
    String url = _endpoint,
  }) {
    when(
      () => apiClient.get<Map<String, dynamic>>(url),
    ).thenAnswer((_) async => payload);
  }

  /// Stubs a network read of [url] failing with [error].
  void stubNetworkError(Object error, {String url = _endpoint}) {
    when(() => apiClient.get<Map<String, dynamic>>(url)).thenThrow(error);
  }

  group('cacheFirst', () {
    test(
      'returns the cached payload without hitting the network when fresh',
      () async {
        stubCacheEntry(_cachedPayload);

        final response = await cache.get<Map<String, dynamic>>(_endpoint);

        expect(response.data, _cachedPayload);
        expect(response.isStale, isFalse);
        verifyNever(() => apiClient.get<Map<String, dynamic>>(any()));
        verifyNever(
          () => localStorage.write<Map<String, dynamic>>(any(), any()),
        );
      },
    );

    test('serves an entry stored exactly at the freshness boundary', () async {
      stubCacheEntry(_cachedPayload, storedAt: simulatedNow.subtract(_maxAge));

      final response = await cache.get<Map<String, dynamic>>(_endpoint);

      expect(response.data, _cachedPayload);
      expect(response.isStale, isFalse);
      verifyNever(() => apiClient.get<Map<String, dynamic>>(any()));
    });

    test(
      'fetches from network and persists when the cache entry is too old',
      () async {
        // Stored 25 hours ago, one hour past the fixed 24 hour window.
        stubCacheEntry(
          _cachedPayload,
          storedAt: simulatedNow.subtract(const Duration(hours: 25)),
        );
        stubNetworkPayload(_networkPayload);

        final response = await cache.get<Map<String, dynamic>>(_endpoint);

        expect(response.data, _networkPayload);
        expect(response.isStale, isFalse);
        verify(() => apiClient.get<Map<String, dynamic>>(_endpoint)).called(1);
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
          storedAt: simulatedNow.subtract(const Duration(hours: 25)),
        );
        stubNetworkError(ApiException(statusCode: 500, message: 'Server down'));

        final response = await cache.get<Map<String, dynamic>>(_endpoint);

        expect(response.data, _cachedPayload);
        expect(response.isStale, isTrue);
        verify(
          () => logger.warning(any(), prefix: any(named: 'prefix')),
        ).called(1);
        // The stale copy is served, never overwritten.
        verifyNever(
          () => localStorage.write<Map<String, dynamic>>(any(), any()),
        );
      },
    );

    test(
      'falls back to the network on a miss and persists the response',
      () async {
        stubCacheEntry(null);
        stubNetworkPayload(_networkPayload);

        final response = await cache.get<Map<String, dynamic>>(_endpoint);

        expect(response.data, _networkPayload);
        expect(response.isStale, isFalse);
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
        stubNetworkPayload(_networkPayload);
        when(
          () => localStorage.write<Map<String, dynamic>>(any(), any()),
        ).thenAnswer((_) => Future.error(Exception('disk full')));

        final response = await cache.get<Map<String, dynamic>>(_endpoint);

        expect(response.data, _networkPayload);
        expect(response.isStale, isFalse);
        verify(
          () => logger.error(any(), prefix: any(named: 'prefix')),
        ).called(1);
      },
    );

    test(
      'a network error on a cache miss propagates unchanged to the caller',
      () async {
        stubCacheEntry(null);
        stubNetworkError(ApiException(statusCode: 404, message: 'not found'));

        await expectLater(
          cache.get<Map<String, dynamic>>(_endpoint),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.message, 'message', 'not found'),
          ),
        );
        verifyNever(
          () => localStorage.write<Map<String, dynamic>>(any(), any()),
        );
      },
    );
  });

  group('forceRefresh', () {
    test('bypasses a fresh cache entry and persists the new payload', () async {
      stubCacheEntry(_cachedPayload);
      stubNetworkPayload(_networkPayload);

      final response = await cache.get<Map<String, dynamic>>(
        _endpoint,
        forceRefresh: true,
      );

      expect(response.data, _networkPayload);
      expect(response.isStale, isFalse);
      verify(() => apiClient.get<Map<String, dynamic>>(_endpoint)).called(1);
      verify(
        () => localStorage.write<Map<String, dynamic>>(
          _endpoint,
          _networkPayload,
        ),
      ).called(1);
    });

    test(
      'still reads the cache entry so it can be served when the refresh fails',
      () async {
        stubCacheEntry(_cachedPayload);
        stubNetworkError(Exception('offline'));

        final response = await cache.get<Map<String, dynamic>>(
          _endpoint,
          forceRefresh: true,
        );

        expect(response.data, _cachedPayload);
        expect(response.isStale, isTrue);
        verify(
          () => localStorage.readEntry<Map<String, dynamic>>(_endpoint),
        ).called(1);
      },
    );

    test(
      'rethrows the original error when a forced refresh fails on a cache miss',
      () async {
        stubCacheEntry(null);
        stubNetworkError(ApiException(message: 'offline', statusCode: 503));

        await expectLater(
          cache.get<Map<String, dynamic>>(_endpoint, forceRefresh: true),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 503),
          ),
        );
      },
    );
  });

  group('in-flight deduplication', () {
    test('concurrent reads of the same url share a single request', () async {
      stubCacheEntry(null);
      final networkCompleter = Completer<Map<String, dynamic>>();
      when(
        () => apiClient.get<Map<String, dynamic>>(_endpoint),
      ).thenAnswer((_) => networkCompleter.future);

      final first = cache.get<Map<String, dynamic>>(_endpoint);
      final second = cache.get<Map<String, dynamic>>(_endpoint);
      networkCompleter.complete(_networkPayload);
      final results = await Future.wait([first, second]);

      expect(results.map((r) => r.data), [_networkPayload, _networkPayload]);
      expect(results.map((r) => r.isStale), [isFalse, isFalse]);
      verify(() => apiClient.get<Map<String, dynamic>>(_endpoint)).called(1);
    });

    test('reads of different urls are not deduplicated', () async {
      stubCacheEntry(null, url: _endpoint);
      stubCacheEntry(null, url: _otherEndpoint);
      stubNetworkPayload(_networkPayload, url: _endpoint);
      when(
        () => apiClient.get<Map<String, dynamic>>(_otherEndpoint),
      ).thenAnswer((_) async => {'name': 'ditto', 'source': 'network'});

      await Future.wait([
        cache.get<Map<String, dynamic>>(_endpoint),
        cache.get<Map<String, dynamic>>(_otherEndpoint),
      ]);

      verify(() => apiClient.get<Map<String, dynamic>>(_endpoint)).called(1);
      verify(
        () => apiClient.get<Map<String, dynamic>>(_otherEndpoint),
      ).called(1);
    });

    test('a failed shared request releases the in-flight slot', () async {
      stubCacheEntry(null);
      stubNetworkError(ApiException(message: 'boom'));

      await expectLater(
        cache.get<Map<String, dynamic>>(_endpoint),
        throwsA(isA<ApiException>()),
      );

      stubNetworkPayload(_networkPayload);
      final response = await cache.get<Map<String, dynamic>>(_endpoint);

      expect(response.data, _networkPayload);
      verify(() => apiClient.get<Map<String, dynamic>>(_endpoint)).called(2);
    });
  });

  group('cache maintenance', () {
    test('clear wipes local storage', () async {
      await cache.clear();

      verify(() => localStorage.clear()).called(1);
    });

    test('size reports the local storage byte size', () async {
      when(() => localStorage.getByteSize()).thenAnswer((_) async => 2048);

      expect(await cache.size(), 2048);
      verify(() => localStorage.getByteSize()).called(1);
    });
  });
}
