import 'dart:io';

import 'package:dio/dio.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/2_application/helpers/log_sanitizer.dart';
import 'package:pokefinder/src/3_domain/helpers/measurement_formatter.dart';
import 'package:pokefinder/src/4_repository/interceptors/logging_interceptor.dart';

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  group('Release Hardening & Compliance Unit Tests', () {
    test(
      'sanitizeQueryForLog redacts queries in release mode and preserves them in debug mode',
      () {
        expect(
          sanitizeQueryForLog('pikachu', isRelease: true),
          equals('[REDACTED]'),
        );
        expect(
          sanitizeQueryForLog('pikachu', isRelease: false),
          equals('pikachu'),
        );
        expect(sanitizeQueryForLog('', isRelease: true), equals('[REDACTED]'));
        expect(sanitizeQueryForLog('', isRelease: false), equals(''));
      },
    );

    test('MeasurementFormatter formats integers with locale', () {
      expect(
        MeasurementFormatter.formatInteger(1000, locale: 'en'),
        equals('1,000'),
      );
      expect(
        MeasurementFormatter.formatInteger(1000, locale: 'it'),
        equals('1.000'),
      );
      expect(
        MeasurementFormatter.formatInteger(45, locale: 'en'),
        equals('45'),
      );
    });

    testWidgets(
      'TranslationExtension translates locations with precomputed keys',
      (tester) async {
        late BuildContext testContext;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
            home: Builder(
              builder: (context) {
                testContext = context;
                return const Placeholder();
              },
            ),
          ),
        );

        expect(
          testContext.translateLocation('pallet-town'),
          equals('Biancavilla'),
        );
        expect(
          testContext.translateLocation('sinnoh-route-201'),
          contains('Percorso 201'),
        );
      },
    );

    test(
      'LoggingInterceptor truncates payloads exceeding maxPayloadLength',
      () {
        final mockLogger = _MockEnLogger();
        final interceptor = LoggingInterceptor(
          logger: mockLogger,
          verbose: true,
        );

        final shortPayload = 'A' * 100;
        final longPayload = 'B' * 1500;

        final requestOptions = RequestOptions(
          path: 'https://pokeapi.co/api/v2/pokemon/1',
        );
        final handler1 = ResponseInterceptorHandler();
        final handler2 = ResponseInterceptorHandler();

        // We test the truncation directly via onResponse
        interceptor.onResponse(
          Response(
            requestOptions: requestOptions,
            data: shortPayload,
            statusCode: 200,
          ),
          handler1,
        );

        verify(
          () => mockLogger.debug(
            '  Response: $shortPayload',
            prefix: any(named: 'prefix'),
          ),
        ).called(1);

        interceptor.onResponse(
          Response(
            requestOptions: requestOptions,
            data: longPayload,
            statusCode: 200,
          ),
          handler2,
        );

        verify(
          () => mockLogger.debug(
            any(that: contains('... [truncated 500 chars]')),
            prefix: any(named: 'prefix'),
          ),
        ).called(1);
      },
    );

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
