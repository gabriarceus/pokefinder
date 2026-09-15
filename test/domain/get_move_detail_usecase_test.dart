import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

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
  late GetMoveDetailUseCase useCase;

  setUp(() {
    repository = _MockPokemonRepository();
    useCase = GetMoveDetailUseCase(repository);
  });

  test('delegates to the repository and returns the move detail', () async {
    when(
      () => repository.getMoveDetail(
        'tackle',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => right(_tackle));

    final result = await useCase('tackle');

    expect(result, right(_tackle));
    verify(
      () => repository.getMoveDetail(
        'tackle',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  test('forwards the cancellation token to the repository', () async {
    final token = CancellationToken();
    when(
      () => repository.getMoveDetail(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => right(_tackle));

    await useCase('tackle', cancelToken: token);

    verify(
      () => repository.getMoveDetail('tackle', cancelToken: token),
    ).called(1);
  });

  test('maps repository failures through', () async {
    const failure = NetworkUnavailableFailure();
    when(
      () => repository.getMoveDetail(
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => left(failure));

    final result = await useCase('tackle');

    expect(result, left(failure));
  });
}
