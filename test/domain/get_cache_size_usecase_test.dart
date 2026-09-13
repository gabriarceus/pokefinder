import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockPokemonRepository repository;
  late GetCacheSizeUseCase useCase;

  setUp(() {
    repository = _MockPokemonRepository();
    useCase = GetCacheSizeUseCase(repository);
  });

  test('calls getCacheSize on repository and returns byte count', () async {
    const expectedBytes = 1024 * 256;
    when(
      () => repository.getCacheSize(),
    ).thenAnswer((_) async => const Right(expectedBytes));

    final result = await useCase();

    expect(result, const Right(expectedBytes));
    verify(() => repository.getCacheSize()).called(1);
  });

  test('returns failure when repository fails', () async {
    const failure = StorageFailure('Disk read error');
    when(
      () => repository.getCacheSize(),
    ).thenAnswer((_) async => const Left(failure));

    final result = await useCase();

    expect(result, const Left(failure));
    verify(() => repository.getCacheSize()).called(1);
  });
}
