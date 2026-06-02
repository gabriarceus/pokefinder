import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';

/// Hive box name used for JSON cache entries.
const _kBoxName = 'data_cache';

/// Internal JSON key for the cached payload.
const _kDataKey = 'data';

/// Internal JSON key for the storage timestamp (milliseconds since epoch).
const _kStoredAtKey = 'storedAt';

/// A [LocalStorage] implementation backed by [Hive].
///
/// Each entry is stored as a JSON-encoded string containing both the
/// original payload and a storage timestamp. This allows [maxAge]-based
/// expiry checks without requiring Hive type adapters.
///
/// Internal storage format:
/// ```json
/// {
///   "data": { ... original payload ... },
///   "storedAt": 1714650000000
/// }
/// ```
@LazySingleton(as: LocalStorage)
class HiveLocalStorage implements LocalStorage {
  HiveLocalStorage();

  /// Lazily opened Hive box, shared across all read/write calls.
  Box<String>? _box;

  /// Opens (or returns the already-opened) Hive box.
  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(_kBoxName);
    return _box!;
  }

  @override
  Future<dynamic> read(String key, {Duration? maxAge}) async {
    final box = await _getBox();
    final raw = box.get(key);
    if (raw == null) return null;

    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final data = envelope[_kDataKey];
    final storedAt = envelope[_kStoredAtKey] as int?;

    if (data == null) return null;

    // If maxAge is specified, check whether the entry has expired.
    if (maxAge != null && storedAt != null) {
      final age = DateTime.now().millisecondsSinceEpoch -
          storedAt; // could be a problem in future testing
      if (age > maxAge.inMilliseconds) return null;
    }

    return data;
  }

  @override
  Future<void> write(String key, dynamic data) async {
    final box = await _getBox();
    final envelope = {
      _kDataKey: data,
      _kStoredAtKey: DateTime.now()
          .millisecondsSinceEpoch, // could be a problem in future testing
    };
    await box.put(key, jsonEncode(envelope));
  }

  @override
  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }
}
