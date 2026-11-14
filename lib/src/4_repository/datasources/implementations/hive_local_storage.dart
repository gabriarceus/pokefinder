import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/local_storage.dart';

/// Hive box name used for JSON cache entries.
const _kBoxName = 'data_cache';

/// Current schema version of the cache envelope.
const kCurrentCacheSchemaVersion = 1;

/// Default maximum number of cached entries before LRU eviction triggers.
const kDefaultMaxCacheEntries = 100;

/// Internal JSON keys for envelope fields.
const _kVersionKey = 'version';
const _kDataKey = 'data';
const _kStoredAtKey = 'storedAt';
const _kPinnedKey = 'pinned';

/// A [LocalStorage] implementation backed by [Hive] with envelope versioning
/// and LRU eviction.
@LazySingleton(as: LocalStorage)
class HiveLocalStorage implements LocalStorage {
  HiveLocalStorage({Clock clock = const Clock()})
    : this.withMaxEntries(clock: clock, maxEntries: kDefaultMaxCacheEntries);

  @visibleForTesting
  HiveLocalStorage.withMaxEntries({
    Clock clock = const Clock(),
    required int maxEntries,
  }) : _clock = clock,
       _maxEntries = maxEntries;

  final Clock _clock;
  final int _maxEntries;

  /// In-memory LRU tracker maintaining access order (least-recently used first).
  final Map<String, int> _accessOrder = <String, int>{};

  /// Keys known to be pinned, so eviction skips them without reading them.
  final Set<String> _pinnedKeys = <String>{};

  /// Lazily opened Hive box, shared across all read/write calls.
  Box<String>? _box;

  /// Opens (or returns the already-opened) Hive box and initializes access tracking.
  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    final box = await Hive.openBox<String>(_kBoxName);
    _box = box;
    for (final key in box.keys) {
      final keyStr = key.toString();
      _accessOrder.putIfAbsent(keyStr, () => 0);
    }
    return box;
  }

  void _recordAccess(String key, int timestampMs) {
    _accessOrder.remove(key);
    _accessOrder[key] = timestampMs;
  }

  @override
  Future<CacheEntry<T>?> readEntry<T>(String key) async {
    final box = await _getBox();
    final raw = box.get(key);
    if (raw == null) return null;

    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return _discard(box, key);
    }
    if (decoded is! Map<String, dynamic>) return _discard(box, key);

    final version = decoded[_kVersionKey];
    final storedAtMs = decoded[_kStoredAtKey];
    final data = decoded[_kDataKey];
    if (version != kCurrentCacheSchemaVersion ||
        storedAtMs is! int ||
        data == null ||
        // Schema drift: the payload cannot be decoded as T, so evict it
        // instead of re-decoding it on every read.
        (T != dynamic && data is! T)) {
      return _discard(box, key);
    }
    if (decoded[_kPinnedKey] == true) _pinnedKeys.add(key);

    final nowMs = _clock.now().millisecondsSinceEpoch;

    // Update in-memory access tracking without re-encoding the full payload to disk
    _recordAccess(key, nowMs);

    return CacheEntry<T>(
      data: data as T,
      storedAt: DateTime.fromMillisecondsSinceEpoch(storedAtMs),
    );
  }

  /// Deletes the malformed or obsolete entry at [key] and returns null.
  Future<CacheEntry<T>?> _discard<T>(Box<String> box, String key) async {
    _accessOrder.remove(key);
    _pinnedKeys.remove(key);
    await box.delete(key);
    return null;
  }

  @override
  Future<void> write<T>(String key, T data, {bool evictable = true}) async {
    final box = await _getBox();
    final nowMs = _clock.now().millisecondsSinceEpoch;

    // If new entry and cache is full, evict the least-recently used entry
    if (!box.containsKey(key) && box.length >= _maxEntries) {
      await _evictLru(box);
    }

    final envelope = {
      _kVersionKey: kCurrentCacheSchemaVersion,
      _kDataKey: data,
      _kStoredAtKey: nowMs,
      _kPinnedKey: !evictable,
    };

    await box.put(key, jsonEncode(envelope));
    _recordAccess(key, nowMs);
    if (evictable) {
      _pinnedKeys.remove(key);
    } else {
      _pinnedKeys.add(key);
    }
  }

  /// Removes the least-recently used entry that is not pinned from [box].
  Future<void> _evictLru(Box<String> box) async {
    bool evictable(String key) {
      if (_pinnedKeys.contains(key)) return false;
      // After a restart the set is empty: the stored envelope is the source.
      // The pinned flag is the last field written by [write].
      if (box.get(key)?.endsWith('"$_kPinnedKey":true}') ?? false) {
        _pinnedKeys.add(key);
        return false;
      }
      return true;
    }

    final candidateKey =
        _accessOrder.keys.where(evictable).firstOrNull ??
        box.keys.map((key) => key.toString()).where(evictable).firstOrNull;
    if (candidateKey != null) {
      _accessOrder.remove(candidateKey);
      await box.delete(candidateKey);
    }
  }

  @override
  Future<void> delete(String key) async {
    _accessOrder.remove(key);
    _pinnedKeys.remove(key);
    final box = await _getBox();
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    _accessOrder.clear();
    _pinnedKeys.clear();
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<int> getByteSize() async {
    final box = await _getBox();
    var totalBytes = 0;
    for (final value in box.values) {
      totalBytes += utf8.encode(value).length;
    }
    return totalBytes;
  }
}
