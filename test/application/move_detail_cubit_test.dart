import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _tackle = MoveDetail(
  id: 33,
  name: 'tackle',
  accuracy: 100,
  power: 40,
  pp: 35,
  type: PokemonType.normal,
  damageClass: DamageClass.physical,
  flavorTexts: {'en': 'A physical attack.'},
);

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late MoveDetailCubit cubit;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    cubit = MoveDetailCubit(repository, logger);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is MoveDetailInitial', () {
    expect(cubit.state, isA<MoveDetailInitial>());
  });

  test('emits loading then the loaded move detail', () async {
    when(
      () => repository.getMoveDetail('tackle'),
    ).thenAnswer((_) async => right(_tackle));

    final emitted = <MoveDetailState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchMoveDetail('tackle');
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [MoveDetailLoading(), const MoveDetailLoaded(_tackle)]);
  });

  test(
    'emits loading then an error carrying the failure message and typed failure',
    () async {
      when(
        () => repository.getMoveDetail(any()),
      ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));

      final emitted = <MoveDetailState>[];
      final subscription = cubit.stream.listen(emitted.add);

      await cubit.fetchMoveDetail('tackle');
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        MoveDetailLoading(),
        const MoveDetailError('offline', failure: UnexpectedFailure('offline')),
      ]);
    },
  );

  test('retrying fetchMoveDetail after error transitions to loaded', () async {
    when(
      () => repository.getMoveDetail('tackle'),
    ).thenAnswer((_) async => left(const UnexpectedFailure('network down')));

    await cubit.fetchMoveDetail('tackle');
    await pumpEventQueue();

    expect(cubit.state, isA<MoveDetailError>());

    when(
      () => repository.getMoveDetail('tackle'),
    ).thenAnswer((_) async => right(_tackle));

    final emitted = <MoveDetailState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchMoveDetail('tackle');
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [MoveDetailLoading(), const MoveDetailLoaded(_tackle)]);
    expect(cubit.state, const MoveDetailLoaded(_tackle));
  });
}
