import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _sampleChain = EvolutionChain(
  id: 1,
  root: EvolutionNode(
    speciesId: 1,
    speciesName: 'bulbasaur',
    speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
    spriteUrl:
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
  ),
);

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late GetEvolutionChainUseCase useCase;
  late EvolutionCubit cubit;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    useCase = GetEvolutionChainUseCase(repository);
    cubit = EvolutionCubit(useCase, logger);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is EvolutionInitial', () {
    expect(cubit.state, isA<EvolutionInitial>());
  });

  test('emits EvolutionLoading then EvolutionLoaded on success', () async {
    when(
      () => repository.getEvolutionChain(
        'https://pokeapi.co/api/v2/evolution-chain/1/',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => right(_sampleChain));

    final emitted = <EvolutionState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchEvolutionChain(
      'https://pokeapi.co/api/v2/evolution-chain/1/',
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [
      const EvolutionLoading(),
      const EvolutionLoaded(_sampleChain),
    ]);
  });

  test('emits EvolutionLoading then EvolutionError on failure', () async {
    when(
      () => repository.getEvolutionChain(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => left(const UnexpectedFailure('evolution error')));

    final emitted = <EvolutionState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchEvolutionChain(
      'https://pokeapi.co/api/v2/evolution-chain/1/',
    );
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [
      const EvolutionLoading(),
      const EvolutionError(
        'evolution error',
        failure: UnexpectedFailure('evolution error'),
      ),
    ]);
  });
}
