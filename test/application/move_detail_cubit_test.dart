import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

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
  late MoveDetailCubit cubit;

  setUp(() {
    repository = _MockPokemonRepository();
    cubit = MoveDetailCubit(repository, _MockEnLogger());
  });

  tearDown(() => cubit.close());

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

  test('emits loading then an error carrying the failure message', () async {
    when(
      () => repository.getMoveDetail(any()),
    ).thenAnswer((_) async => left(const UnexpectedFailure('offline')));

    final emitted = <MoveDetailState>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.fetchMoveDetail('tackle');
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [MoveDetailLoading(), const MoveDetailError('offline')]);
  });
}
