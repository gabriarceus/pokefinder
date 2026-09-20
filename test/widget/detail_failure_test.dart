import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/failure.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

Widget _wrapWithLocalizations(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets(
    'DetailFailure displays localized message and handles retry/edit',
    (tester) async {
      var retryCalled = false;
      var editCalled = false;

      await tester.pumpWidget(
        _wrapWithLocalizations(
          DetailFailure(
            state: PokemonBlocFailure(const NetworkUnavailableFailure()),
            pokemonName: 'pikachu',
            onRetry: () => retryCalled = true,
            onEditSearch: () => editCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error icon and localized message
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(
        find.text('No internet connection. Please check your network.'),
        findsOneWidget,
      );

      // Verify Retry button works
      final retryFinder = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryFinder, findsOneWidget);
      await tester.tap(retryFinder);
      expect(retryCalled, isTrue);

      // Verify Edit Search button works
      final editFinder = find.widgetWithText(OutlinedButton, 'Edit Search');
      expect(editFinder, findsOneWidget);
      await tester.tap(editFinder);
      expect(editCalled, isTrue);
    },
  );

  testWidgets('DetailFailure displays PokemonNotFoundFailure correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithLocalizations(
        DetailFailure(
          state: PokemonBlocFailure(PokemonNotFoundFailure()),
          pokemonName: 'notapokemon',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    expect(find.text('Pokémon not found.'), findsOneWidget);
  });

  testWidgets('DetailFailure displays ServerFailure correctly', (tester) async {
    await tester.pumpWidget(
      _wrapWithLocalizations(
        DetailFailure(
          state: PokemonBlocFailure(const ServerFailure(503)),
          pokemonName: 'charizard',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    expect(
      find.text('Server error occurred. Please try again later.'),
      findsOneWidget,
    );
  });
}
