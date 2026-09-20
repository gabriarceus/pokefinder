import 'package:clock/clock.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';
import 'package:pokefinder/src/4_repository/repositories/fetch_strategy.dart';
import 'package:pokefinder/src/4_repository/services/request_deduplicator.dart';

/// Metadata describing the origin and freshness of data returned by [DataRepository].
class CacheMetadata extends Equatable {
  const CacheMetadata({
    required this.isFresh,
    required this.isStale,
    required this.fromCache,
    this.cachedAt,
  });

  const CacheMetadata.network()
    : isFresh = true,
      isStale = false,
      fromCache = false,
      cachedAt = null;

  const CacheMetadata.cacheFresh({this.cachedAt})
    : isFresh = true,
      isStale = false,
      fromCache = true;

  const CacheMetadata.cacheStale({this.cachedAt})
    : isFresh = false,
      isStale = true,
      fromCache = true;

  final bool isFresh;
  final bool isStale;
  final bool fromCache;
  final DateTime? cachedAt;

  @override
  List<Object?> get props => [isFresh, isStale, fromCache, cachedAt];
}

/// A wrapper holding the payload and its corresponding [CacheMetadata].
class DataResponse<T> extends Equatable {
  const DataResponse({required this.data, required this.metadata});

  final T data;
  final CacheMetadata metadata;

  @override
  List<Object?> get props => [data, metadata];
}

/// A generic, feature-agnostic repository that caches JSON payloads
/// retrieved from a remote API.
@injectable
class DataRepository {
  DataRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
    required EnLogger logger,
    Clock clock = const Clock(),
    RequestDeduplicator? deduplicator,
  }) : _apiClient = apiClient,
       _localStorage = localStorage,
       _logger = logger,
       _clock = clock,
       _deduplicator = deduplicator ?? RequestDeduplicator();

  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  final EnLogger _logger;
  final Clock _clock;
  final RequestDeduplicator _deduplicator;

  /// Generation epoch incremented on each clearCache to invalidate lagging in-flight writes.
  int _cacheEpoch = 0;

  /// Logging prefix used in all log messages emitted by this class.
  static const prefix = 'DataRepository';

  /// Fetches JSON data from [endpoint] according to the given [strategy].
  Future<DataResponse<T>> fetchData<T>(
    String endpoint, {
    FetchStrategy strategy = FetchStrategy.cacheFirst,
    Duration? maxAge,
    CancelToken? cancelToken,
  }) {
    final writeEpoch = _cacheEpoch;
    return switch (strategy) {
      FetchStrategy.cacheFirst => _cacheFirst<T>(
        endpoint,
        writeEpoch: writeEpoch,
        maxAge: maxAge,
        cancelToken: cancelToken,
      ),
      FetchStrategy.networkFirst => _networkFirst<T>(
        endpoint,
        writeEpoch: writeEpoch,
        maxAge: maxAge,
        cancelToken: cancelToken,
      ),
      FetchStrategy.networkOnly => _networkOnly<T>(
        endpoint,
        writeEpoch: writeEpoch,
        cancelToken: cancelToken,
      ),
    };
  }

  /// Removes all cached entries from local storage and cancels lagging writes.
  Future<void> clearCache() async {
    _cacheEpoch++;
    _logger.debug('Clearing all cached entries', prefix: prefix);
    await _localStorage.clear();
  }

  /// Returns the approximate size of cached data in bytes.
  Future<int> getCacheSize() => _localStorage.getByteSize();

  /// Removes a single cached entry identified by [key].
  Future<void> invalidate(String key) async {
    _logger.debug('Invalidating cache for: $key', prefix: prefix);
    await _localStorage.delete(key);
  }

  /// **Cache-first**: reads from cache; on fresh hit returns cached payload.
  /// If missing or expired, fetches from network with request deduplication.
  /// If network fails while an expired cached entry exists, returns the cached entry
  /// flagged as stale (`stale-if-error`).
  Future<DataResponse<T>> _cacheFirst<T>(
    String endpoint, {
    required int writeEpoch,
    Duration? maxAge,
    CancelToken? cancelToken,
  }) async {
    _logger.debug('Attempting cache lookup for: $endpoint', prefix: prefix);

    final entry = await _localStorage.readEntry<T>(endpoint);
    if (entry != null && entry.isFresh(maxAge, now: _clock.now())) {
      _logger.debug('Fresh cache hit for: $endpoint', prefix: prefix);
      return DataResponse<T>(
        data: entry.data,
        metadata: CacheMetadata.cacheFresh(cachedAt: entry.storedAt),
      );
    }

    _logger.debug(
      'Cache miss or expired for: $endpoint — fetching from network',
      prefix: prefix,
    );

    try {
      final data = await _deduplicator.run<T>(
        endpoint,
        () => _apiClient.get<T>(endpoint, cancelToken: cancelToken),
      );

      await _safePersist<T>(endpoint, data, writeEpoch);

      return DataResponse<T>(
        data: data,
        metadata: const CacheMetadata.network(),
      );
    } catch (networkError) {
      if (networkError is ApiException && networkError.isCancelled) {
        rethrow;
      }
      // Stale-if-error fallback
      if (entry != null) {
        _logger.warning(
          'Network failed for $endpoint ($networkError) — returning stale cached record',
          prefix: prefix,
        );
        return DataResponse<T>(
          data: entry.data,
          metadata: CacheMetadata.cacheStale(cachedAt: entry.storedAt),
        );
      }
      rethrow;
    }
  }

  /// **Network-first**: attempts network request and persists the result.
  /// On failure, falls back to cached data (even if expired). If cache is also empty,
  /// throws [DataFetchException].
  Future<DataResponse<T>> _networkFirst<T>(
    String endpoint, {
    required int writeEpoch,
    Duration? maxAge,
    CancelToken? cancelToken,
  }) async {
    _logger.debug('Attempting network request for: $endpoint', prefix: prefix);

    try {
      final data = await _deduplicator.run<T>(
        endpoint,
        () => _apiClient.get<T>(endpoint, cancelToken: cancelToken),
      );
      _logger.debug(
        'Network success for: $endpoint — persisting to cache',
        prefix: prefix,
      );

      await _safePersist<T>(endpoint, data, writeEpoch);

      return DataResponse<T>(
        data: data,
        metadata: const CacheMetadata.network(),
      );
    } catch (e) {
      if (e is ApiException && e.isCancelled) {
        rethrow;
      }
      _logger.debug(
        'Network request failed for: $endpoint — falling back to cache',
        prefix: prefix,
      );

      final entry = await _localStorage.readEntry<T>(endpoint);
      if (entry != null) {
        final isFresh = entry.isFresh(maxAge, now: _clock.now());
        _logger.debug('Cache fallback hit for: $endpoint', prefix: prefix);
        return DataResponse<T>(
          data: entry.data,
          metadata: isFresh
              ? CacheMetadata.cacheFresh(cachedAt: entry.storedAt)
              : CacheMetadata.cacheStale(cachedAt: entry.storedAt),
        );
      }

      _logger.debug(
        'Cache fallback miss for: $endpoint — no data available',
        prefix: prefix,
      );
      throw DataFetchException(
        'Failed to fetch data for "$endpoint". '
        'Network request failed and no cached data is available.',
      );
    }
  }

  /// **Network-only**: always fetches from network and persists to cache.
  Future<DataResponse<T>> _networkOnly<T>(
    String endpoint, {
    required int writeEpoch,
    CancelToken? cancelToken,
  }) async {
    _logger.debug(
      'Performing network-only fetch for: $endpoint',
      prefix: prefix,
    );

    final data = await _deduplicator.run<T>(
      endpoint,
      () => _apiClient.get<T>(endpoint, cancelToken: cancelToken),
    );

    _logger.debug(
      'Network success for: $endpoint — updating cache',
      prefix: prefix,
    );
    await _safePersist<T>(endpoint, data, writeEpoch);

    return DataResponse<T>(data: data, metadata: const CacheMetadata.network());
  }

  /// Persists [data] under [endpoint] if the cache has not been cleared since [epoch].
  ///
  /// Awaits the write so that the epoch check and the I/O are atomic from the
  /// caller's perspective, preventing a [clearCache] call from being undone by
  /// a write that was dispatched but not yet completed.
  /// Swallows write errors so cache write failures never break network retrieval.
  Future<void> _safePersist<T>(String endpoint, T data, int epoch) async {
    if (epoch != _cacheEpoch) {
      _logger.debug(
        'Discarding outdated cache write for: $endpoint after cache clear',
        prefix: prefix,
      );
      return;
    }

    try {
      await _localStorage.write<T>(endpoint, data);
      if (epoch != _cacheEpoch) {
        _logger.debug(
          'Cache was cleared during write for: $endpoint — evicting',
          prefix: prefix,
        );
        await _localStorage.delete(endpoint);
      }
    } catch (error) {
      _logger.error(
        'Failed to persist cache for: $endpoint — $error',
        prefix: prefix,
      );
    }
  }
}

/// Thrown when [DataRepository] is unable to retrieve data from both network and local cache.
class DataFetchException implements Exception {
  DataFetchException(this.message);

  /// A human-readable description of the failure.
  final String message;

  @override
  String toString() => 'DataFetchException: $message';
}
