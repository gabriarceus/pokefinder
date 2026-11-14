import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/alternate_forms_widget.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_form_details_cubit/pokemon_form_details_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '../fixtures/pokemon_fixture.dart';
import '../helpers/pump_app.dart';

class _MockPokemonBloc extends Mock implements PokemonDetailBloc {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SelectPokemonFormEvent(const PokemonForm(name: 'fallback', url: '')),
    );
  });

  late _MockPokemonBloc mockBloc;
  late _MockPokemonRepository repository;

  setUp(() {
    mockBloc = _MockPokemonBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    repository = _MockPokemonRepository();
    when(
      () => repository.getFormDetails(any()),
    ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));
    getIt.registerFactory<PokemonFormDetailsCubit>(
      () => PokemonFormDetailsCubit(EnLogger(), repository),
    );
  });

  tearDown(() => getIt.unregister<PokemonFormDetailsCubit>());

  Future<void> pumpWidgetUnderTest(
    WidgetTester tester, {
    required Pokemon pokemon,
    String? selectedFormName,
  }) {
    return tester.pumpApp(
      home: Scaffold(
        body: BlocProvider<PokemonDetailBloc>.value(
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
    testWidgets(
      'a pending switch can be replaced or cancelled from the gallery',
      (tester) async {
        await mockNetworkImagesFor(() async {
          const forms = [
            PokemonForm(name: 'meowth', url: 'url/52/'),
            PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
          ];
          final pokemon = buildPokemon(name: 'meowth', forms: forms);
          when(() => mockBloc.state).thenReturn(
            PokemonDetailSuccess(pokemon: pokemon, isLoadingForm: true),
          );
          await pumpWidgetUnderTest(tester, pokemon: pokemon);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Alolan Meowth'));
          await tester.tap(find.text('Meowth'));
          verify(
            () => mockBloc.add(SelectPokemonFormEvent(forms[1])),
          ).called(1);
          verify(
            () => mockBloc.add(SelectPokemonFormEvent(forms[0])),
          ).called(1);
        });
      },
    );
    testWidgets('renders nothing when pokemon has 1 or fewer forms', (
      tester,
    ) async {
      final pokemon = buildPokemon(
        forms: [const PokemonForm(name: 'bulbasaur', url: 'url/1/')],
      );

      await pumpWidgetUnderTest(tester, pokemon: pokemon);
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
          ).thenReturn(PokemonDetailSuccess(pokemon: pokemon));

          await pumpWidgetUnderTest(tester, pokemon: pokemon);
          await tester.pumpAndSettle();

          expect(find.text('Alternate Forms'), findsOneWidget);
          expect(find.text('Charizard'), findsOneWidget);
          expect(find.text('Mega Charizard X'), findsOneWidget);
          expect(find.text('Mega Charizard Y'), findsOneWidget);
          expect(find.text('Current Form'), findsOneWidget);

          // Verify form type badges
          expect(find.text('Dragon'), findsOneWidget);
          expect(find.text('Flying'), findsWidgets);
          expect(find.text('Fire'), findsWidgets);
        });
      },
    );

    testWidgets('shows the loaded types of a form that has none', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        when(
          () => repository.getFormDetails(
            PokeApiUrlHelper.pokemonUrl('meowth-alola'),
          ),
        ).thenAnswer(
          (_) async => right(
            const PokemonFormDetails(
              id: 10107,
              name: 'meowth-alola',
              type1: PokemonType.dark,
              spriteDefault: '',
              spriteShiny: '',
              artworkDefault: '',
              artworkShiny: '',
            ),
          ),
        );
        final pokemon = buildPokemon(
          name: 'meowth',
          forms: const [
            PokemonForm(
              name: 'meowth',
              url: 'url/52/',
              type1: PokemonType.normal,
            ),
            PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
          ],
        );
        when(
          () => mockBloc.state,
        ).thenReturn(PokemonDetailSuccess(pokemon: pokemon));

        await pumpWidgetUnderTest(tester, pokemon: pokemon);
        await tester.pumpAndSettle();

        expect(find.text('Dark'), findsOneWidget);
      });
    });

    testWidgets('loads the types again after the shown form changes', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        PokemonFormDetails details(String name, int id, PokemonType type) =>
            PokemonFormDetails(
              id: id,
              name: name,
              type1: type,
              spriteDefault: '',
              spriteShiny: '',
              artworkDefault: '',
              artworkShiny: '',
            );
        when(
          () => repository.getFormDetails(
            PokeApiUrlHelper.pokemonUrl('meowth-alola'),
          ),
        ).thenAnswer(
          (_) async => right(details('meowth-alola', 10107, PokemonType.dark)),
        );
        when(
          () =>
              repository.getFormDetails(PokeApiUrlHelper.pokemonUrl('meowth')),
        ).thenAnswer(
          (_) async => right(details('meowth', 52, PokemonType.normal)),
        );
        final base = buildPokemon(
          name: 'meowth',
          forms: const [
            PokemonForm(
              name: 'meowth',
              url: 'url/52/',
              type1: PokemonType.normal,
            ),
            PokemonForm(name: 'meowth-alola', url: 'url/10107/'),
          ],
        );
        final alola = buildPokemon(
          name: 'meowth-alola',
          forms: const [
            PokemonForm(name: 'meowth', url: 'url/52/'),
            PokemonForm(
              name: 'meowth-alola',
              url: 'url/10107/',
              type1: PokemonType.dark,
            ),
          ],
        );
        when(
          () => mockBloc.state,
        ).thenReturn(PokemonDetailSuccess(pokemon: base));
        await pumpWidgetUnderTest(tester, pokemon: base);
        await tester.pumpAndSettle();

        when(
          () => mockBloc.state,
        ).thenReturn(PokemonDetailSuccess(pokemon: alola));
        await pumpWidgetUnderTest(tester, pokemon: alola);
        await tester.pumpAndSettle();

        expect(find.text('Normal'), findsOneWidget);
        expect(find.text('Dark'), findsOneWidget);
      });
    });

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
        ).thenReturn(PokemonDetailSuccess(pokemon: pokemon));

        await pumpWidgetUnderTest(
          tester,
          pokemon: pokemon,
          selectedFormName: 'meowth',
        );
        await tester.pumpAndSettle();

        final alolaFinder = find.text('Alolan Meowth');
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
          ).thenReturn(PokemonDetailSuccess(pokemon: pokemon));

          await pumpWidgetUnderTest(
            tester,
            pokemon: pokemon,
            selectedFormName: 'meowth',
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
