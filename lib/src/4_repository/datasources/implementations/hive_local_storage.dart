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
const _kLastAccessedAtKey = 'lastAccessedAt';

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
      // Corrupt JSON string: evict immediately
      _accessOrder.remove(key);
      await box.delete(key);
      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      // Non-map JSON envelope: evict immediately
      _accessOrder.remove(key);
      await box.delete(key);
      return null;
    }

    final envelope = decoded;

    // Schema version validation
    final version = envelope[_kVersionKey];
    if (version is! int || version != kCurrentCacheSchemaVersion) {
      _accessOrder.remove(key);
      await box.delete(key);
      return null;
    }

    // Timestamp validation
    final storedAtMs = envelope[_kStoredAtKey];
    if (storedAtMs is! int) {
      _accessOrder.remove(key);
      await box.delete(key);
      return null;
    }

    // Payload validation
    final data = envelope[_kDataKey];
    if (data == null) {
      _accessOrder.remove(key);
      await box.delete(key);
      return null;
    }

    if (T != dynamic && data is! T) {
      return null;
    }

    final nowMs = _clock.now().millisecondsSinceEpoch;
    final lastAccessedAtMs =
        _accessOrder[key] ??
        (envelope[_kLastAccessedAtKey] as int?) ??
        storedAtMs;

    // Update in-memory access tracking without re-encoding the full payload to disk
    _recordAccess(key, nowMs);

    return CacheEntry<T>(
      data: data as T,
      storedAt: DateTime.fromMillisecondsSinceEpoch(storedAtMs),
      lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(lastAccessedAtMs),
      schemaVersion: version,
    );
  }

  @override
  Future<T?> read<T>(String key, {Duration? maxAge}) async {
    final entry = await readEntry<T>(key);
    if (entry == null) return null;

    if (maxAge != null && !entry.isFresh(maxAge, now: _clock.now())) {
      return null;
    }

    return entry.data;
  }

  @override
  Future<void> write<T>(String key, T data) async {
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
      _kLastAccessedAtKey: nowMs,
    };

    await box.put(key, jsonEncode(envelope));
    _recordAccess(key, nowMs);
  }

  /// Finds and removes the least-recently used entry from [box] in O(1).
  Future<void> _evictLru(Box<String> box) async {
    final candidateKey =
        _accessOrder.keys.firstOrNull ?? box.keys.firstOrNull?.toString();
    if (candidateKey != null) {
      _accessOrder.remove(candidateKey);
      await box.delete(candidateKey);
    }
  }

  @override
  Future<void> delete(String key) async {
    _accessOrder.remove(key);
    final box = await _getBox();
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    _accessOrder.clear();
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
