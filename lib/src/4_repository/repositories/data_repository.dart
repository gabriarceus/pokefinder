import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';
import 'package:pokefinder/src/4_repository/repositories/fetch_strategy.dart';

/// A generic, feature-agnostic repository that caches JSON payloads
/// retrieved from a remote API.
///
/// [DataRepository] delegates network requests to an [ApiClient] and
/// persists/retrieves responses via a [LocalStorage] implementation.
/// The caller selects the caching behaviour through [FetchStrategy]
/// and may optionally specify a [maxAge] to enforce time-based
/// cache expiry.
///
/// Usage:
/// ```dart
/// final data = await dataRepository.fetchData(
///   'https://api.example.com/resource/42',
///   strategy: FetchStrategy.cacheFirst,
///   maxAge: Duration(hours: 24),
/// );
/// ```
@injectable
class DataRepository {
  DataRepository({
    required ApiClient apiClient,
    required LocalStorage localStorage,
    required EnLogger logger,
  })  : _apiClient = apiClient,
        _localStorage = localStorage,
        _logger = logger;

  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  final EnLogger _logger;

  /// Logging prefix used in all log messages emitted by this class.
  static const prefix = 'DataRepository';

  /// Fetches JSON data from [endpoint] according to the given [strategy].
  ///
  /// When [maxAge] is provided and [strategy] is [FetchStrategy.cacheFirst],
  /// cached entries older than [maxAge] are treated as a cache miss, causing
  /// a fresh network request. For other strategies, [maxAge] is ignored.
  ///
  /// Returns a [Map<String, dynamic>] representing the decoded JSON payload.
  ///
  /// The exhaustive switch on [FetchStrategy] guarantees a compile-time
  /// error if a new variant is added without handling it here.
  Future<dynamic> fetchData(
    String endpoint, {
    FetchStrategy strategy = FetchStrategy.cacheFirst,
    Duration? maxAge,
  }) {
    // Exhaustive switch — adding a new enum value without a corresponding
    // case will produce a compile-time error.
    return switch (strategy) {
      FetchStrategy.cacheFirst => _cacheFirst(endpoint, maxAge: maxAge),
      FetchStrategy.networkFirst => _networkFirst(endpoint),
      FetchStrategy.networkOnly => _networkOnly(endpoint),
    };
  }

  /// Removes all cached entries from local storage.
  ///
  /// Intended to be called from a user-facing "clear cache" action.
  Future<void> clearCache() async {
    _logger.debug('Clearing all cached entries', prefix: prefix);
    await _localStorage.clear();
  }

  /// Removes a single cached entry identified by [key].
  Future<void> invalidate(String key) async {
    _logger.debug('Invalidating cache for: $key', prefix: prefix);
    await _localStorage.delete(key);
  }

  /// **Cache-first**: reads from cache; on miss (or expiry), fetches from
  /// network, persists the result, and returns it.
  Future<dynamic> _cacheFirst(
    String endpoint, {
    Duration? maxAge,
  }) async {
    _logger.debug('Attempting cache lookup for: $endpoint', prefix: prefix);

    final cached = await _localStorage.read(endpoint, maxAge: maxAge);
    if (cached != null) {
      _logger.debug('Cache hit for: $endpoint', prefix: prefix);
      return cached;
    }

    _logger.debug('Cache miss for: $endpoint — fetching from network',
        prefix: prefix);
    final data = await _apiClient.get(endpoint);

    // Persist asynchronously — do not await; the caller should not be
    // blocked by the write operation. A write failure is logged and
    // swallowed so it never affects the returned payload.
    _localStorage.write(endpoint, data).catchError((Object error) {
      _logger.error('Failed to persist cache for: $endpoint — $error',
          prefix: prefix);
    });

    return data;
  }

  /// **Network-first**: attempts a network request and persists the result.
  /// On failure, falls back to cached data. If the cache is also empty,
  /// throws an explicit [DataFetchException].
  Future<dynamic> _networkFirst(String endpoint) async {
    _logger.debug('Attempting network request for: $endpoint', prefix: prefix);

    try {
      final data = await _apiClient.get(endpoint);
      _logger.debug('Network success for: $endpoint — persisting to cache',
          prefix: prefix);
      await _localStorage.write(endpoint, data);
      return data;
    } catch (e) {
      _logger.debug(
          'Network request failed for: $endpoint — falling back to cache',
          prefix: prefix);

      final cached = await _localStorage.read(endpoint);
      if (cached != null) {
        _logger.debug('Cache fallback hit for: $endpoint', prefix: prefix);
        return cached;
      }

      _logger.debug('Cache fallback miss for: $endpoint — no data available',
          prefix: prefix);
      throw DataFetchException(
        'Failed to fetch data for "$endpoint". '
        'Network request failed and no cached data is available.',
      );
    }
  }

  /// **Network-only**: always fetches from the network and persists the
  /// result to keep the cache up to date. Returns the fresh payload.
  Future<dynamic> _networkOnly(String endpoint) async {
    _logger.debug('Performing network-only fetch for: $endpoint',
        prefix: prefix);

    final data = await _apiClient.get(endpoint);

    _logger.debug('Network success for: $endpoint — updating cache',
        prefix: prefix);
    await _localStorage.write(endpoint, data);

    return data;
  }
}

/// Thrown when [DataRepository] is unable to retrieve data from both the
/// network and the local cache.
class DataFetchException implements Exception {
  DataFetchException(this.message);

  /// A human-readable description of the failure.
  final String message;

  @override
  String toString() => 'DataFetchException: $message';
}
