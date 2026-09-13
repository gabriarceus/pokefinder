import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/alternate_forms_widget.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockPokemonBloc extends Mock implements PokemonBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SelectPokemonFormEvent(const PokemonForm(name: 'fallback', url: '')),
    );
  });

  late _MockPokemonBloc mockBloc;

  setUp(() {
    mockBloc = _MockPokemonBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildWidgetUnderTest({
    required Pokemon pokemon,
    String? selectedFormName,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<PokemonBloc>.value(
          value: mockBloc,
          child: AlternateFormsWidget(
            pokemon: pokemon,
            typeColor: Colors.blue,
            textColor: Colors.black,
            selectedFormName: selectedFormName,
          ),
        ),
      ),
    );
  }

  group('AlternateFormsWidget', () {
    testWidgets('renders nothing when pokemon has 1 or fewer forms', (
      tester,
    ) async {
      final pokemon = buildPokemon(
        forms: [const PokemonForm(name: 'bulbasaur', url: 'url/1/')],
      );

      await tester.pumpWidget(buildWidgetUnderTest(pokemon: pokemon));
      await tester.pumpAndSettle();

      expect(find.byType(AlternateFormsWidget), findsOneWidget);
      expect(find.text('Alternate Forms'), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
      'renders alternate forms gallery when pokemon has multiple forms',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final pokemon = buildPokemon(
            name: 'charizard',
            forms: const [
              PokemonForm(
                name: 'charizard',
                url: 'url/6/',
                type1: PokemonType.fire,
                type2: PokemonType.flying,
              ),
              PokemonForm(
                name: 'charizard-mega-x',
                url: 'url/10034/',
                type1: PokemonType.fire,
                type2: PokemonType.dragon,
              ),
              PokemonForm(
                name: 'charizard-mega-y',
                url: 'url/10035/',
                type1: PokemonType.fire,
                type2: PokemonType.flying,
              ),
            ],
          );

          when(
            () => mockBloc.state,
          ).thenReturn(PokemonBlocSuccess(pokemon: pokemon));

          await tester.pumpWidget(buildWidgetUnderTest(pokemon: pokemon));
          await tester.pumpAndSettle();

          expect(find.text('Alternate Forms'), findsOneWidget);
          expect(find.text('Charizard'), findsOneWidget);
          expect(find.text('Charizard - Mega X'), findsOneWidget);
          expect(find.text('Charizard - Mega Y'), findsOneWidget);
          expect(find.text('Current Form'), findsOneWidget);

          // Verify form type badges
          expect(find.text('Dragon'), findsOneWidget);
          expect(find.text('Flying'), findsWidgets);
          expect(find.text('Fire'), findsWidgets);
        });
      },
    );

    testWidgets('tapping non-selected form dispatches SelectPokemonFormEvent', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final forms = const [
          PokemonForm(name: 'meowth', url: 'url/52/'),
          PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
          PokemonForm(name: 'meowth-galar', url: 'url/10161/'),
        ];
        final pokemon = buildPokemon(name: 'meowth', forms: forms);

        when(
          () => mockBloc.state,
        ).thenReturn(PokemonBlocSuccess(pokemon: pokemon));

        await tester.pumpWidget(
          buildWidgetUnderTest(pokemon: pokemon, selectedFormName: 'meowth'),
        );
        await tester.pumpAndSettle();

        final alolaFinder = find.text('Meowth - Alola');
        expect(alolaFinder, findsOneWidget);

        await tester.tap(alolaFinder);
        await tester.pump();

        verify(
          () => mockBloc.add(
            SelectPokemonFormEvent(
              const PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
            ),
          ),
        ).called(1);
      });
    });

    testWidgets(
      'tapping already selected form does not dispatch duplicate event',
      (tester) async {
        await mockNetworkImagesFor(() async {
          final forms = const [
            PokemonForm(name: 'meowth', url: 'url/52/'),
            PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
          ];
          final pokemon = buildPokemon(name: 'meowth', forms: forms);

          when(
            () => mockBloc.state,
          ).thenReturn(PokemonBlocSuccess(pokemon: pokemon));

          await tester.pumpWidget(
            buildWidgetUnderTest(pokemon: pokemon, selectedFormName: 'meowth'),
          );
          await tester.pumpAndSettle();

          final meowthFinder = find.text('Meowth');
          expect(meowthFinder, findsOneWidget);

          await tester.tap(meowthFinder);
          await tester.pump();

          verifyNever(() => mockBloc.add(any()));
        });
      },
    );
  });
}
