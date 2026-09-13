import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _sampleAbility = AbilityDetail(
  id: 65,
  name: 'overgrow',
  flavorTexts: {'en': 'Ups GRASS moves in a pinch.'},
  effects: {'en': 'When HP is low, Grass moves do 1.5x damage.'},
  shortEffects: {'en': 'Ups Grass moves at low HP.'},
);

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late GetAbilityDetailUseCase useCase;
  late AbilityDetailCubit cubit;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    useCase = GetAbilityDetailUseCase(repository);
    cubit = AbilityDetailCubit(useCase, logger);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is AbilityDetailInitial', () {
    expect(cubit.state, isA<AbilityDetailInitial>());
  });

  test(
    'emits AbilityDetailLoading then AbilityDetailLoaded on success',
    () async {
      when(
        () => repository.getAbilityDetail(
          'overgrow',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => right(_sampleAbility));

      final emitted = <AbilityDetailState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.fetchAbilityDetail('overgrow');
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        const AbilityDetailLoading(),
        const AbilityDetailLoaded(_sampleAbility),
      ]);
    },
  );

  test(
    'emits AbilityDetailLoading then AbilityDetailError on failure',
    () async {
      when(
        () => repository.getAbilityDetail(
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => left(const UnexpectedFailure('ability error')));

      final emitted = <AbilityDetailState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.fetchAbilityDetail('overgrow');
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        const AbilityDetailLoading(),
        const AbilityDetailError(
          'ability error',
          failure: UnexpectedFailure('ability error'),
        ),
      ]);
    },
  );
}
