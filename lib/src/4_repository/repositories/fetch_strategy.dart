/// Defines the strategy used by [DataRepository] when fetching data.
///
/// Each variant determines the priority between cached data and fresh
/// network responses, as well as fallback behaviour on failure.
enum FetchStrategy {
  /// Attempts to read from cache first. On a cache miss, falls back to a
  /// network request and persists the result in cache before returning.
  cacheFirst,

  /// Attempts a network request first, persisting the result in cache.
  /// On network failure, falls back to cached data. If both fail, an
  /// exception is thrown.
  networkFirst,

  /// Always performs a network request, ignoring any cached data.
  /// The fresh response is still persisted in cache to keep it up to date.
  networkOnly,
}
