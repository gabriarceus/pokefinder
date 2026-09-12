import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';

/// Deduplicates concurrent in-flight asynchronous operations identified by a key.
@lazySingleton
class RequestDeduplicator {
  final Map<String, Future<dynamic>> _inFlight = {};

  /// Executes [action] or joins an already in-flight operation for [key].
  ///
  /// If the joined in-flight operation is cancelled, joining callers retry
  /// with their own [action].
  Future<T> run<T>(
    String key,
    Future<T> Function() action, {
    bool Function(Object error)? isCancelled,
  }) async {
    final existing = _inFlight[key];
    if (existing != null) {
      try {
        final result = await existing;
        return result as T;
      } catch (e) {
        final cancelled = isCancelled?.call(e) ?? _defaultIsCancelled(e);
        if (cancelled) {
          if (identical(_inFlight[key], existing)) {
            _inFlight.remove(key);
          }
          return run(key, action, isCancelled: isCancelled);
        }
        rethrow;
      }
    }

    final future = action();
    _inFlight[key] = future;

    try {
      return await future;
    } finally {
      if (identical(_inFlight[key], future)) {
        _inFlight.remove(key);
      }
    }
  }

  static bool _defaultIsCancelled(Object error) {
    if (error is ApiException && error.isCancelled) return true;
    return false;
  }

  /// True if there is currently an in-flight request for [key].
  bool isInFlight(String key) => _inFlight.containsKey(key);

  /// Number of currently in-flight requests.
  int get activeCount => _inFlight.length;
}
