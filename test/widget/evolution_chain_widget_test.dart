import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/evolution_chain_widget.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class MockGetEvolutionChainUseCase extends Mock
    implements GetEvolutionChainUseCase {}

void main() {
  late MockGetEvolutionChainUseCase mockGetEvolutionChainUseCase;

  setUpAll(() async {
    await configureDependencies('mock');
    registerFallbackValue(CancellationToken());
  });

  setUp(() {
    mockGetEvolutionChainUseCase = MockGetEvolutionChainUseCase();
    if (getIt.isRegistered<EvolutionCubit>()) {
      getIt.unregister<EvolutionCubit>();
    }
    getIt.registerFactory<EvolutionCubit>(
      () => EvolutionCubit(mockGetEvolutionChainUseCase, getIt<EnLogger>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<EvolutionCubit>()) {
      getIt.unregister<EvolutionCubit>();
    }
    getIt.registerFactory<EvolutionCubit>(
      () =>
          EvolutionCubit(getIt<GetEvolutionChainUseCase>(), getIt<EnLogger>()),
    );
  });

  const sampleLinearChain = EvolutionChain(
    id: 1,
    root: EvolutionNode(
      speciesId: 1,
      speciesName: 'bulbasaur',
      speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
      spriteUrl: 'https://example.com/1.png',
      evolvesTo: [
        EvolutionNode(
          speciesId: 2,
          speciesName: 'ivysaur',
          speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/2/',
          spriteUrl: 'https://example.com/2.png',
          triggers: [
            EvolutionTriggerDetail(
              triggerType: EvolutionTriggerType.levelUp,
              minLevel: 16,
            ),
          ],
          evolvesTo: [
            EvolutionNode(
              speciesId: 3,
              speciesName: 'venusaur',
              speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/3/',
              spriteUrl: 'https://example.com/3.png',
              triggers: [
                EvolutionTriggerDetail(
                  triggerType: EvolutionTriggerType.levelUp,
                  minLevel: 32,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  const sampleBranchedChain = EvolutionChain(
    id: 67,
    root: EvolutionNode(
      speciesId: 133,
      speciesName: 'eevee',
      speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/133/',
      spriteUrl: 'https://example.com/133.png',
      evolvesTo: [
        EvolutionNode(
          speciesId: 134,
          speciesName: 'vaporeon',
          speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/134/',
          spriteUrl: 'https://example.com/134.png',
          triggers: [
            EvolutionTriggerDetail(
              triggerType: EvolutionTriggerType.useItem,
              item: 'water-stone',
            ),
          ],
        ),
        EvolutionNode(
          speciesId: 135,
          speciesName: 'jolteon',
          speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/135/',
          spriteUrl: 'https://example.com/135.png',
          triggers: [
            EvolutionTriggerDetail(
              triggerType: EvolutionTriggerType.useItem,
              item: 'thunder-stone',
            ),
          ],
        ),
      ],
    ),
  );

  Widget createTestWidget({
    required String chainUrl,
    required String currentPokemon,
    List<RouteBase>? routes,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes:
          routes ??
          [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: SingleChildScrollView(
                  child: EvolutionChainWidget(
                    evolutionChainUrl: chainUrl,
                    currentPokemonName: currentPokemon,
                    typeColor: Colors.green,
                    textColor: Colors.black,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/pokemon/:name',
              builder: (context, state) => Scaffold(
                body: Text('Pokemon: ${state.pathParameters['name']}'),
              ),
            ),
          ],
    );

    return MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  group('EvolutionChainWidget Widget Tests', () {
    testWidgets(
      'renders linear evolution chain with trigger levels and navigates on tap',
      (tester) async {
        when(
          () => mockGetEvolutionChainUseCase(
            'https://pokeapi.co/api/v2/evolution-chain/1/',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Right(sampleLinearChain));

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            createTestWidget(
              chainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
              currentPokemon: 'bulbasaur',
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Bulbasaur'), findsOneWidget);
          expect(find.text('Ivysaur'), findsOneWidget);
          expect(find.text('Venusaur'), findsOneWidget);
          expect(find.text('Lv. 16'), findsOneWidget);
          expect(find.text('Lv. 32'), findsOneWidget);

          // Tap Ivysaur to navigate
          await tester.tap(find.text('Ivysaur'));
          await tester.pumpAndSettle();

          expect(find.text('Pokemon: ivysaur'), findsOneWidget);
        });
      },
    );

    testWidgets('renders branched evolution chain with item triggers', (
      tester,
    ) async {
      when(
        () => mockGetEvolutionChainUseCase(
          'https://pokeapi.co/api/v2/evolution-chain/67/',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Right(sampleBranchedChain));

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            chainUrl: 'https://pokeapi.co/api/v2/evolution-chain/67/',
            currentPokemon: 'eevee',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Eevee'), findsOneWidget);
        expect(find.text('Vaporeon'), findsOneWidget);
        expect(find.text('Jolteon'), findsOneWidget);
        expect(find.text('Use Water Stone'), findsOneWidget);
        expect(find.text('Use Thunder Stone'), findsOneWidget);
      });
    });

    testWidgets('renders error state and retries on tap', (tester) async {
      when(
        () => mockGetEvolutionChainUseCase(
          'https://pokeapi.co/api/v2/evolution-chain/1/',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(500, 'Error loading chain')),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            chainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
            currentPokemon: 'bulbasaur',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

        // Reset mock to success for retry
        when(
          () => mockGetEvolutionChainUseCase(
            'https://pokeapi.co/api/v2/evolution-chain/1/',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Right(sampleLinearChain));

        await tester.tap(find.byIcon(Icons.refresh_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Bulbasaur'), findsOneWidget);
        expect(find.text('Ivysaur'), findsOneWidget);
      });
    });

    testWidgets(
      'exposes proper semantics for current and non-current pokemon nodes',
      (tester) async {
        when(
          () => mockGetEvolutionChainUseCase(
            'https://pokeapi.co/api/v2/evolution-chain/1/',
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => const Right(sampleLinearChain));

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(
            createTestWidget(
              chainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
              currentPokemon: 'bulbasaur',
            ),
          );
          await tester.pumpAndSettle();

          // Bulbasaur is the current pokemon
          final currentSemantics = tester.getSemantics(find.text('Bulbasaur'));
          expect(currentSemantics.label, contains('Bulbasaur'));
          expect(currentSemantics.label, contains('Current Pokémon'));

          // Ivysaur is not current
          final nextSemantics = tester.getSemantics(find.text('Ivysaur'));
          expect(nextSemantics.label, contains('Ivysaur'));
          expect(nextSemantics.label, isNot(contains('Current Pokémon')));
        });
      },
    );
  });
}
