/// Represents a validated cached item alongside its envelope metadata.
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.storedAt,
    this.schemaVersion = 1,
  });

  /// The cached payload.
  final T data;

  /// Timestamp when the entry was originally stored.
  final DateTime storedAt;

  /// Schema version of the cache envelope.
  final int schemaVersion;

  /// Checks if this entry is within [maxAge] relative to [now].
  bool isFresh(Duration? maxAge, {required DateTime now}) {
    if (maxAge == null) return true;
    return now.difference(storedAt) <= maxAge;
  }

  /// Checks if this entry has exceeded [maxAge] relative to [now].
  bool isStale(Duration? maxAge, {required DateTime now}) =>
      !isFresh(maxAge, now: now);
}

/// An abstract interface for local key-value storage of JSON payloads.
///
/// Implementations may use any persistence backend (e.g. Hive, Isar,
/// SharedPreferences). The contract operates on key-value pairs keyed by
/// a [String] identifier, typically derived from the API endpoint.
abstract class LocalStorage {
  /// Reads a cache entry with envelope metadata associated with [key].
  ///
  /// Returns `null` if no entry exists or if the envelope is malformed/obsolete.
  Future<CacheEntry<T>?> readEntry<T>(String key);

  /// Persists [data] under the given [key], overwriting any existing entry.
  Future<void> write<T>(String key, T data);

  /// Removes the entry associated with [key], if it exists.
  Future<void> delete(String key);

  /// Removes all stored entries.
  Future<void> clear();

  /// Returns the approximate storage size in bytes.
  Future<int> getByteSize();
}
