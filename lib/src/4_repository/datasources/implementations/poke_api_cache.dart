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

  /// Network requests currently running, keyed by URL.
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
    final entry = await _localStorage.readEntry<T>(url);
    if (!forceRefresh &&
        entry != null &&
        entry.isFresh(_kMaxAge, now: _clock.now())) {
      return (data: entry.data, isStale: false);
    }

    try {
      final data = await _fetchShared<T>(url);
      await _persist(url, data);
      return (data: data, isStale: false);
    } catch (error) {
      if (entry == null) rethrow;
      _logger.warning(
        'Request failed for $url ($error), serving the cached copy',
        prefix: _prefix,
      );
      return (data: entry.data, isStale: true);
    }
  }

  /// Removes every cached payload.
  Future<void> clear() => _localStorage.clear();

  /// Returns the approximate size of the cached payloads, in bytes.
  Future<int> size() => _localStorage.getByteSize();

  /// Joins the running request for [url], or starts a new one.
  Future<T> _fetchShared<T>(String url) async {
    final running = _inFlight[url];
    if (running != null) return await running as T;

    final request = _apiClient.get<T>(url);
    _inFlight[url] = request;
    try {
      return await request;
    } finally {
      _inFlight.remove(url);
    }
  }

  Future<void> _persist<T>(String url, T data) async {
    try {
      await _localStorage.write<T>(url, data);
    } catch (error) {
      // A failed write only costs a later refetch; the caller still gets data.
      _logger.error('Failed to cache $url: $error', prefix: _prefix);
    }
  }
}
