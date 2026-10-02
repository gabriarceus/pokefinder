import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Release platform configuration', () {
    test('AndroidManifest.xml satisfies release compliance', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);

      final content = manifestFile.readAsStringSync();
      expect(content.contains('android:usesCleartextTraffic'), isFalse);
      expect(content.contains('android.permission.WAKE_LOCK'), isFalse);
      expect(content.contains('android.permission.INTERNET'), isTrue);
      expect(content.contains('android:label="@string/app_name"'), isTrue);
    });

    test('Android adaptive icons reference separate foreground drawable', () {
      final foregroundFile = File(
        'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
      );
      expect(foregroundFile.existsSync(), isTrue);

      for (final path in [
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
      ]) {
        final iconFile = File(path);
        expect(iconFile.existsSync(), isTrue);
        final content = iconFile.readAsStringSync();
        expect(
          content.contains(
            'android:drawable="@drawable/ic_launcher_foreground"',
          ),
          isTrue,
        );
        expect(content.contains('@mipmap/ic_launcher'), isFalse);
      }
    });

    test('iOS Info.plist satisfies App Store review compliance', () {
      final plistFile = File('ios/Runner/Info.plist');
      expect(plistFile.existsSync(), isTrue);

      final content = plistFile.readAsStringSync();
      expect(content.contains('NSMicrophoneUsageDescription'), isFalse);
      expect(content.contains('NSLocalNetworkUsageDescription'), isFalse);
      expect(content.contains('NSAllowsArbitraryLoads'), isFalse);
      expect(content.contains('<string>audio</string>'), isFalse);
    });
  });
}
