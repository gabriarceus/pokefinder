import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/tabs/detail_info_tab.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../fixtures/pokemon_fixture.dart';
import '../helpers/in_memory_hydrated_storage.dart';
import '../helpers/pump_app.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockCryAudioController extends Mock implements CryAudioController {}

void main() {
  late _MockPokemonRepository repository;
  late IPokemonRepository originalRepository;

  setUpAll(() async {
    ensureHydratedStorage();
    await configureDependencies(Environment.dev);
    originalRepository = getIt<IPokemonRepository>();
  });

  setUp(() {
    repository = _MockPokemonRepository();
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(repository);
  });

  tearDown(() {
    getIt.unregister<IPokemonRepository>();
    getIt.registerSingleton<IPokemonRepository>(originalRepository);
  });

  testWidgets(
    'marks the species node as current when the Pokémon name differs',
    (tester) async {
      const chainUrl = 'https://pokeapi.co/api/v2/evolution-chain/1/';
      when(() => repository.getPokemonSpecies(any())).thenAnswer(
        (_) async => right(
          const PokemonSpecies(
            id: 487,
            name: 'giratina',
            flavorTexts: [],
            genera: {},
            evolutionChainUrl: chainUrl,
          ),
        ),
      );
      when(() => repository.getEvolutionChain(chainUrl)).thenAnswer(
        (_) async => right(
          const EvolutionChain(
            id: 1,
            root: EvolutionNode(
              speciesId: 487,
              speciesName: 'giratina',
              speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/487/',
              spriteUrl: 'https://example.com/487.png',
              evolvesTo: [
                EvolutionNode(
                  speciesId: 2,
                  speciesName: 'ivysaur',
                  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/2/',
                  spriteUrl: 'https://example.com/2.png',
                  triggers: [
                    EvolutionTriggerDetail(
                      triggerType: EvolutionTriggerType.levelUp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      final audio = _MockCryAudioController();
      when(() => audio.state).thenReturn(const CryPlaybackState());
      when(
        () => audio.stateStream,
      ).thenAnswer((_) => const Stream<CryPlaybackState>.empty());
      final pokemon = buildPokemon(
        id: 487,
        name: 'giratina-altered',
        speciesName: 'giratina',
      );
      final versions = DetailGameVersionCubit()..initialize(pokemon);
      addTearDown(versions.close);

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(
          home: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: const SliverToBoxAdapter(child: SizedBox()),
                ),
              ],
              body: BlocProvider<DetailGameVersionCubit>.value(
                value: versions,
                child: DetailInfoTab(
                  pokemon: pokemon,
                  audioController: audio,
                  onFormTap: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.scrollUntilVisible(
          find.text('Giratina'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
      });

      expect(
        tester.getSemantics(find.text('Giratina')).label,
        contains('Current Pokémon'),
      );
      expect(
        tester.getSemantics(find.text('Ivysaur')).label,
        isNot(contains('Current Pokémon')),
      );
    },
    semanticsEnabled: true,
  );
}
