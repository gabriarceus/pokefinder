import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/startup_error/startup_error_page.dart';

void main() {
  group('StartupErrorPage', () {
    testWidgets('renders title, message, and calls onRetry when tapped', (
      tester,
    ) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: StartupErrorPage(
            onRetry: () => retryCalled = true,
            errorMessage: 'Storage path unavailable',
          ),
        ),
      );

      expect(find.text('Startup Failed'), findsOneWidget);
      expect(find.text('Storage path unavailable'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets(
      'renders localized fallback message when errorMessage is omitted',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: StartupErrorPage(onRetry: () {}),
          ),
        );

        expect(find.text('Startup Failed'), findsOneWidget);
        expect(
          find.text(
            'An error occurred while initializing app storage. Please try again.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders Italian localization correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: StartupErrorPage(onRetry: () {}),
        ),
      );

      expect(find.text('Avvio non riuscito'), findsOneWidget);
      expect(
        find.text(
          "Si è verificato un errore durante l'inizializzazione della memoria. Riprova.",
        ),
        findsOneWidget,
      );
      expect(find.text('Riprova'), findsOneWidget);
    });
  });
}
