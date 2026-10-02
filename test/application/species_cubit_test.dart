import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/species_cubit/species_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/species_cubit/species_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _sampleSpecies = PokemonSpecies(
  id: 1,
  name: 'bulbasaur',
  flavorTexts: [
    PokemonSpeciesFlavorText(
      text: 'A strange seed was planted on its back at birth.',
      language: 'en',
      version: 'red',
    ),
  ],
  genera: {'en': 'Seed Pokémon'},
);

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late SpeciesCubit cubit;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    cubit = SpeciesCubit(repository, logger);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('emits SpeciesLoading then SpeciesLoaded on success', () async {
    when(
      () => repository.getPokemonSpecies(
        'https://pokeapi.co/api/v2/pokemon-species/1/',
      ),
    ).thenAnswer((_) async => right(_sampleSpecies));

    final emitted = <SpeciesState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchSpecies('https://pokeapi.co/api/v2/pokemon-species/1/');
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [
      const SpeciesLoading(),
      const SpeciesLoaded(_sampleSpecies),
    ]);
  });

  test('emits SpeciesLoading then SpeciesError on failure', () async {
    when(
      () => repository.getPokemonSpecies(any()),
    ).thenAnswer((_) async => left(const UnexpectedFailure('species error')));

    final emitted = <SpeciesState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchSpecies('https://pokeapi.co/api/v2/pokemon-species/1/');
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [
      const SpeciesLoading(),
      const SpeciesError(
        'species error',
        failure: UnexpectedFailure('species error'),
      ),
    ]);
  });

  test(
    'recovering from error emits SpeciesLoading then SpeciesLoaded',
    () async {
      when(
        () => repository.getPokemonSpecies(any()),
      ).thenAnswer((_) async => left(const UnexpectedFailure('error')));

      await cubit.fetchSpecies('https://pokeapi.co/api/v2/pokemon-species/1/');
      await pumpEventQueue();
      expect(cubit.state, isA<SpeciesError>());

      when(
        () => repository.getPokemonSpecies(any()),
      ).thenAnswer((_) async => right(_sampleSpecies));

      final emitted = <SpeciesState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.fetchSpecies('https://pokeapi.co/api/v2/pokemon-species/1/');
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        const SpeciesLoading(),
        const SpeciesLoaded(_sampleSpecies),
      ]);
    },
  );
}
