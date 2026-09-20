import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pokefinder/bootstrap/mobile_storage_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MobileStorageInitializer and Platform Support', () {
    test(
      'declares Android and iOS as officially supported mobile platforms',
      () {
        expect(kSupportedPlatforms, contains(TargetPlatform.android));
        expect(kSupportedPlatforms, contains(TargetPlatform.iOS));
        expect(kSupportedPlatforms, hasLength(2));
      },
    );

    test('separates durable and disposable directories cleanly', () async {
      final tempRoot = Directory.systemTemp.createTempSync('poke_test_');
      final docsDir = Directory('${tempRoot.path}/documents');
      final cacheDir = Directory('${tempRoot.path}/cache');

      try {
        await initializeMobileStorage(
          getDurableStorageDirectory: () async => docsDir,
          getDisposableCacheDirectory: () async => cacheDir,
          initAudio: () {},
        );

        // Verify durable storage is initialized and writes to documents directory
        expect(HydratedBloc.storage, isNotNull);
        await HydratedBloc.storage.write('test_pref', 'dark_theme');
        expect(HydratedBloc.storage.read('test_pref'), equals('dark_theme'));

        expect(File('${docsDir.path}/hydrated_box.hive').existsSync(), isTrue);
        expect(
          File('${cacheDir.path}/hydrated_box.hive').existsSync(),
          isFalse,
        );

        // Verify disposable Hive cache writes to temporary cache directory
        final cacheBox = await Hive.openBox<String>('api_cache_test');
        await cacheBox.put('pokemon_1', 'bulbasaur');
        expect(
          File('${cacheDir.path}/api_cache_test.hive').existsSync(),
          isTrue,
        );
        expect(
          File('${docsDir.path}/api_cache_test.hive').existsSync(),
          isFalse,
        );
        await cacheBox.close();
      } finally {
        try {
          await HydratedBloc.storage.close();
          tempRoot.deleteSync(recursive: true);
        } catch (_) {
          // In Windows, open file handles may prevent synchronous deletion during test execution.
        }
      }
    });
  });
}
