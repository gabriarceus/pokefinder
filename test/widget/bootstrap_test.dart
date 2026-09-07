import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/main.dart';
import 'package:pokefinder/src/1_presentation/pages/startup_error/startup_error_page.dart';

void main() {
  group('bootstrap startup and error recovery', () {
    testWidgets('renders StartupErrorApp when storage initialization throws', (
      tester,
    ) async {
      Widget? renderedApp;

      await bootstrap(
        then: () => const Text('App Started'),
        initializeStorage: () async {
          throw Exception('Failed to access documents directory');
        },
        appRunner: (widget) {
          renderedApp = widget;
        },
      );

      expect(renderedApp, isNotNull);
      expect(renderedApp, isA<StartupErrorApp>());

      await tester.pumpWidget(renderedApp!);
      await tester.pumpAndSettle();

      expect(find.byType(StartupErrorPage), findsOneWidget);
      expect(find.text('Startup Failed'), findsOneWidget);
      expect(
        find.textContaining('Failed to access documents directory'),
        findsOneWidget,
      );
    });

    testWidgets('retry re-attempts bootstrap execution', (tester) async {
      Widget? renderedApp;
      var attempts = 0;

      await bootstrap(
        then: () => const Text('App Started'),
        initializeStorage: () async {
          attempts++;
          if (attempts == 1) {
            throw Exception('Temporary storage error');
          }
        },
        appRunner: (widget) {
          renderedApp = widget;
        },
      );

      expect(attempts, equals(1));
      expect(renderedApp, isA<StartupErrorApp>());

      await tester.pumpWidget(renderedApp!);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(attempts, equals(2));
      expect(renderedApp, isA<Text>());
    });

    test(
      'rapid successive calls to configureDependencies re-register without collision',
      () async {
        await configureDependencies('mock');
        await configureDependencies('mock');
        expect(getIt.isRegistered<EnLogger>(), isTrue);
      },
    );
  });
}
