import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';

/// Time after which a cached payload is fetched again.
const _kMaxAge = Duration(hours: 24);

/// Cache-first JSON client for PokeAPI endpoints.
@lazySingleton
class PokeApiCache {
  PokeApiCache({
    required ApiClient apiClient,
    required LocalStorage localStorage,
    required EnLogger logger,
    Clock clock = const Clock(),
  }) : _apiClient = apiClient,
       _localStorage = localStorage,
       _logger = logger,
       _clock = clock;

  static const _prefix = 'PokeApiCache';

  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  final EnLogger _logger;
  final Clock _clock;

  /// Incremented by every [clear] so writes started before it can be dropped.
  int _epoch = 0;

  /// Network requests currently running, keyed by URL and payload type.
  final Map<String, Future<Object?>> _inFlight = {};

  /// Returns the JSON payload for [url].
  ///
  /// Serves a cached entry younger than 24 hours, unless [forceRefresh] is
  /// true. Otherwise fetches the payload and stores it. When the request fails
  /// and a cached entry exists, returns that entry with `isStale: true`;
  /// without a cached entry, rethrows the request error.
  Future<({T data, bool isStale})> get<T>(
    String url, {
    bool forceRefresh = false,
  }) async {
    // Captured before the first await, so a clear() racing with the cache
    // lookup still invalidates this request's write.
    final epoch = _epoch;

    // A forced refresh discards the cached entry, so decoding it up front
    // would only pay for the stale-if-error fallback below.
    CacheEntry<T>? entry;
    if (!forceRefresh) {
      entry = await _localStorage.readEntry<T>(url);
      if (entry != null && entry.isFresh(_kMaxAge, now: _clock.now())) {
        return (data: entry.data, isStale: false);
      }
    }

    try {
      final data = await _fetchShared<T>(url);
      await _persist(url, data, epoch);
      return (data: data, isStale: false);
    } catch (error) {
      final fallback = entry ?? await _localStorage.readEntry<T>(url);
      if (fallback == null) rethrow;
      _logger.warning(
        'Request failed for $url ($error), serving the cached copy',
        prefix: _prefix,
      );
      return (data: fallback.data, isStale: true);
    }
  }

  /// Removes every cached payload.
  Future<void> clear() async {
    // Bumping first: a request already in flight sees a different epoch and
    // drops its write instead of resurrecting what was just cleared.
    _epoch++;
    await _localStorage.clear();
  }

  /// Returns the approximate size of the cached payloads, in bytes.
  Future<int> size() => _localStorage.getByteSize();

  /// Joins the running request for [url], or starts a new one.
  Future<T> _fetchShared<T>(String url) async {
    final key = '$url#$T';
    final running = _inFlight[key];
    if (running != null) return await running as T;

    final request = _apiClient.get<T>(url);
    _inFlight[key] = request;
    try {
      return await request;
    } finally {
      _inFlight.remove(key);
    }
  }

  /// Stores [data] under [url] unless a [clear] started after [epoch].
  Future<void> _persist<T>(String url, T data, int epoch) async {
    if (epoch != _epoch) {
      _logger.info(
        'Not caching $url: the cache was cleared while the request ran',
        prefix: _prefix,
      );
      return;
    }
    try {
      await _localStorage.write<T>(url, data);
    } catch (error) {
      // A failed write only costs a later refetch; the caller still gets data.
      _logger.error('Failed to cache $url: $error', prefix: _prefix);
    }
    // A clear that landed while the write was in flight has already wiped the
    // box, so this key is either ours or gone: either way it must not survive.
    if (epoch != _epoch) await _localStorage.delete(url);
  }
}
