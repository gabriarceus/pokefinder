/// An abstract interface for local key-value storage of JSON payloads.
///
/// Implementations may use any persistence backend (e.g. Hive, Isar,
/// SharedPreferences). The contract operates on raw JSON maps keyed by
/// a [String] identifier, typically derived from the API endpoint.
///
/// Implementations are responsible for tracking storage timestamps when
/// [maxAge] is used in [read], and must return `null` for expired entries.
abstract class LocalStorage {
  /// Reads a previously stored JSON map associated with [key].
  ///
  /// Returns `null` if no entry exists for [key], or if [maxAge] is
  /// provided and the entry was stored longer ago than [maxAge].
  Future<Map<String, dynamic>?> read(String key, {Duration? maxAge});

  /// Persists [data] under the given [key], overwriting any existing entry.
  ///
  /// Implementations should store a timestamp alongside the data so that
  /// [maxAge]-based expiry can be evaluated on subsequent [read] calls.
  Future<void> write(String key, Map<String, dynamic> data);

  /// Removes the entry associated with [key], if it exists.
  Future<void> delete(String key);

  /// Removes all stored entries.
  Future<void> clear();
}
