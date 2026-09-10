import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/form_selection_bottom_sheet.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockPokemonBloc extends Mock implements PokemonBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SelectPokemonFormEvent(const PokemonForm(name: 'fallback', url: '')),
    );
  });

  late _MockPokemonBloc bloc;

  setUp(() {
    bloc = _MockPokemonBloc();
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    bloc.close();
  });

  testWidgets(
    'FormSelectionBottomSheet renders failure banner, retry and rollback buttons',
    (tester) async {
      const failedForm = PokemonForm(name: 'venusaur-mega', url: 'form/10033/');
      final pokemon = buildPokemon(
        name: 'venusaur',
        forms: [
          const PokemonForm(name: 'venusaur', url: 'form/3/'),
          failedForm,
        ],
      );

      final successState = PokemonBlocSuccess(
        pokemon: pokemon,
        selectedFormDetails: PokemonFormDetails.fromPokemon(pokemon),
        formFailure: const NetworkUnavailableFailure(),
        failedForm: failedForm,
      );

      when(() => bloc.state).thenReturn(successState);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<PokemonBloc>.value(
            value: bloc,
            child: Scaffold(
              body: FormSelectionBottomSheet(
                pokemon: pokemon,
                typeColor: Colors.green,
                textColor: Colors.white,
                showShiny: false,
                onShinyChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error banner is visible with localized message
      expect(
        find.text('No internet connection. Please check your network.'),
        findsOneWidget,
      );

      // Verify Retry button is present and dispatches SelectPokemonFormEvent for failedForm
      final retryFinder = find.widgetWithText(TextButton, 'Retry');
      expect(retryFinder, findsOneWidget);
      await tester.tap(retryFinder);
      verify(() => bloc.add(SelectPokemonFormEvent(failedForm))).called(1);

      // Verify Reset to default form button is present and dispatches SelectPokemonFormEvent with base form
      final rollbackFinder = find.widgetWithText(
        TextButton,
        'Reset to default form',
      );
      expect(rollbackFinder, findsOneWidget);
      await tester.tap(rollbackFinder);
      verify(
        () => bloc.add(
          SelectPokemonFormEvent(PokemonForm(name: pokemon.name, url: '')),
        ),
      ).called(1);
    },
  );
}
