import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pokefinder/src/4_repository/datasources/implementations/hive_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveLocalStorage storage;
  late DateTime simulatedTime;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_local_storage_test_');
    Hive.init(tempDir.path);
    simulatedTime = DateTime(2026, 1, 1, 12, 0, 0);
    storage = HiveLocalStorage.withMaxEntries(
      clock: Clock(() => simulatedTime),
      maxEntries: 3,
    );
  });

  tearDown(() async {
    try {
      await Hive.close();
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('writes and reads back payload with metadata', () async {
    const key = 'test_key';
    const payload = {'name': 'pikachu', 'id': 25};

    await storage.write(key, payload);

    final entry = await storage.readEntry<Map<String, dynamic>>(key);
    expect(entry, isNotNull);
    expect(entry!.data, payload);
    expect(entry.schemaVersion, 1);
    expect(entry.storedAt, simulatedTime);

    final direct = await storage.read<Map<String, dynamic>>(key);
    expect(direct, payload);
  });

  test('respects maxAge expiry', () async {
    const key = 'test_key';
    const payload = {'name': 'pikachu'};

    await storage.write(key, payload);

    // Within maxAge: hit
    simulatedTime = simulatedTime.add(const Duration(hours: 1));
    final hit = await storage.read<Map<String, dynamic>>(
      key,
      maxAge: const Duration(hours: 2),
    );
    expect(hit, payload);

    // Beyond maxAge: miss in read(), but readEntry() still returns expired entry for stale fallback
    simulatedTime = simulatedTime.add(const Duration(hours: 3));
    final miss = await storage.read<Map<String, dynamic>>(
      key,
      maxAge: const Duration(hours: 2),
    );
    expect(miss, isNull);

    final staleEntry = await storage.readEntry<Map<String, dynamic>>(key);
    expect(staleEntry, isNotNull);
    expect(
      staleEntry!.isStale(const Duration(hours: 2), now: simulatedTime),
      isTrue,
    );
  });

  test('evicts corrupt JSON string safely', () async {
    final box = await Hive.openBox<String>('data_cache');
    await box.put('corrupt_key', '{not a valid json');

    final entry = await storage.readEntry('corrupt_key');
    expect(entry, isNull);
    expect(box.containsKey('corrupt_key'), isFalse);
  });

  test('evicts non-map JSON string safely', () async {
    final box = await Hive.openBox<String>('data_cache');
    await box.put('array_key', '[1, 2, 3]');

    final entry = await storage.readEntry('array_key');
    expect(entry, isNull);
    expect(box.containsKey('array_key'), isFalse);
  });

  test('evicts envelope with obsolete or invalid schema version', () async {
    final box = await Hive.openBox<String>('data_cache');
    await box.put(
      'obsolete_key',
      jsonEncode({
        'version': 999,
        'data': {'foo': 'bar'},
        'storedAt': simulatedTime.millisecondsSinceEpoch,
      }),
    );

    final entry = await storage.readEntry('obsolete_key');
    expect(entry, isNull);
    expect(box.containsKey('obsolete_key'), isFalse);
  });

  test('evicts envelope with malformed storedAt timestamp', () async {
    final box = await Hive.openBox<String>('data_cache');
    await box.put(
      'bad_timestamp',
      jsonEncode({
        'version': 1,
        'data': {'foo': 'bar'},
        'storedAt': 'not_an_int',
      }),
    );

    final entry = await storage.readEntry('bad_timestamp');
    expect(entry, isNull);
    expect(box.containsKey('bad_timestamp'), isFalse);
  });

  test(
    'returns null without deleting entry when payload type does not match requested generic',
    () async {
      await storage.write('str_key', 'hello');

      // Requesting Map<String, dynamic> when String was stored
      final entry = await storage.readEntry<Map<String, dynamic>>('str_key');
      expect(entry, isNull);

      // Verify the key was not destructively evicted
      final box = await Hive.openBox<String>('data_cache');
      expect(box.containsKey('str_key'), isTrue);

      final validEntry = await storage.readEntry<String>('str_key');
      expect(validEntry?.data, 'hello');
    },
  );

  test(
    'readEntry does not rewrite payload back to storage on cache hit',
    () async {
      const key = 'payload_key';
      const payload = {'name': 'pikachu'};
      await storage.write(key, payload);

      final box = await Hive.openBox<String>('data_cache');
      final rawBefore = box.get(key);

      simulatedTime = simulatedTime.add(const Duration(minutes: 5));
      final entry = await storage.readEntry<Map<String, dynamic>>(key);

      expect(entry?.data, payload);
      final rawAfter = box.get(key);
      expect(rawAfter, equals(rawBefore));
    },
  );

  test('enforces maxEntries bound using LRU eviction', () async {
    // maxEntries is configured to 3
    await storage.write('k1', 'val1');
    simulatedTime = simulatedTime.add(const Duration(seconds: 1));
    await storage.write('k2', 'val2');
    simulatedTime = simulatedTime.add(const Duration(seconds: 1));
    await storage.write('k3', 'val3');

    // Access k1 so k2 becomes least-recently used
    simulatedTime = simulatedTime.add(const Duration(seconds: 1));
    await storage.readEntry('k1');

    // Writing 4th entry should evict k2 (least recently accessed)
    simulatedTime = simulatedTime.add(const Duration(seconds: 1));
    await storage.write('k4', 'val4');

    final box = await Hive.openBox<String>('data_cache');
    expect(box.length, 3);
    expect(box.containsKey('k1'), isTrue);
    expect(box.containsKey('k2'), isFalse); // Evicted!
    expect(box.containsKey('k3'), isTrue);
    expect(box.containsKey('k4'), isTrue);
  });

  test('clear and delete remove entries properly', () async {
    await storage.write('k1', 'val1');
    await storage.write('k2', 'val2');

    await storage.delete('k1');
    expect(await storage.read('k1'), isNull);
    expect(await storage.read('k2'), isNotNull);

    await storage.clear();
    expect(await storage.read('k2'), isNull);
  });
}
