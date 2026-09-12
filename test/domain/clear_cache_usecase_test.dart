import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/usecases/clear_cache_usecase.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockPokemonRepository repository;
  late ClearCacheUseCase useCase;

  setUp(() {
    repository = _MockPokemonRepository();
    useCase = ClearCacheUseCase(repository);
  });

  test(
    'delegates clearCache call to repository and returns right(unit) on success',
    () async {
      when(
        () => repository.clearCache(),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase();

      expect(result, const Right(unit));
      verify(() => repository.clearCache()).called(1);
    },
  );

  test(
    'delegates clearCache call to repository and returns left(failure) on error',
    () async {
      const failure = StorageFailure('Disk error');
      when(
        () => repository.clearCache(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase();

      expect(result, const Left(failure));
      verify(() => repository.clearCache()).called(1);
    },
  );
}
