import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';
import '../helpers/in_memory_hydrated_storage.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockEnLogger logger;
  late _MockPokemonRepository repository;
  late InMemoryHydratedStorage storage;

  setUp(() {
    logger = _MockEnLogger();
    repository = _MockPokemonRepository();
    storage = InMemoryHydratedStorage();
    HydratedBloc.storage = storage;
  });

  PreferencesCubit buildCubit() {
    return PreferencesCubit(logger, repository);
  }

  group('PreferencesCubit', () {
    test('updates themeMode, unitSystem, and autoPlayCry', () {
      final cubit = buildCubit();

      cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state.themeMode, ThemeMode.dark);

      cubit.setUnitSystem(UnitSystem.imperial);
      expect(cubit.state.unitSystem, UnitSystem.imperial);

      cubit.setAutoPlayCry(true);
      expect(cubit.state.autoPlayCry, isTrue);
    });

    test('clamps cryVolume between 0.0 and 1.0', () {
      final cubit = buildCubit();

      cubit.setCryVolume(0.5);
      expect(cubit.state.cryVolume, equals(0.5));

      cubit.setCryVolume(-0.2);
      expect(cubit.state.cryVolume, equals(0.0));

      cubit.setCryVolume(1.5);
      expect(cubit.state.cryVolume, equals(1.0));
    });

    test(
      'refreshCacheSize updates cacheSizeBytes from the repository',
      () async {
        when(
          () => repository.getCacheSize(),
        ).thenAnswer((_) async => const Right(2048));

        final cubit = buildCubit();
        await cubit.refreshCacheSize();

        expect(cubit.state.cacheSizeBytes, equals(2048));
        verify(() => repository.getCacheSize()).called(1);
      },
    );

    test('refreshCacheSize keeps the previous value on failure', () async {
      when(
        () => repository.getCacheSize(),
      ).thenAnswer((_) async => left(const StorageFailure('disk full')));

      final cubit = buildCubit();
      await cubit.refreshCacheSize();

      expect(cubit.state.cacheSizeBytes, equals(0));
    });

    test(
      'clearCache invokes the repository and refreshes cache size',
      () async {
        when(
          () => repository.clearCache(),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => repository.getCacheSize(),
        ).thenAnswer((_) async => const Right(0));

        final cubit = buildCubit();
        await cubit.clearCache();
        await pumpEventQueue();

        expect(cubit.state.cacheSizeBytes, equals(0));
        verify(() => repository.clearCache()).called(1);
        verify(() => repository.getCacheSize()).called(1);
      },
    );

    test('clearCache keeps the previous size when clearing fails', () async {
      when(
        () => repository.getCacheSize(),
      ).thenAnswer((_) async => const Right(2048));
      when(
        () => repository.clearCache(),
      ).thenAnswer((_) async => left(const StorageFailure('read only')));

      final cubit = buildCubit();
      await cubit.refreshCacheSize();
      await cubit.clearCache();
      await pumpEventQueue();

      expect(cubit.state.cacheSizeBytes, equals(2048));
      // The refresh after a failed clear must not run.
      verify(() => repository.getCacheSize()).called(1);
      verify(() => repository.clearCache()).called(1);
    });

    test('persists state across cubit restarts', () async {
      when(
        () => repository.getCacheSize(),
      ).thenAnswer((_) async => const Right(0));
      when(
        () => repository.clearCache(),
      ).thenAnswer((_) async => const Right(unit));

      final cubit1 = buildCubit();
      cubit1.setThemeMode(ThemeMode.light);
      cubit1.setUnitSystem(UnitSystem.imperial);
      cubit1.setAutoPlayCry(true);
      cubit1.setCryVolume(0.75);

      await cubit1.close();

      final cubit2 = buildCubit();
      expect(cubit2.state.themeMode, ThemeMode.light);
      expect(cubit2.state.unitSystem, UnitSystem.imperial);
      expect(cubit2.state.autoPlayCry, isTrue);
      expect(cubit2.state.cryVolume, equals(0.75));
    });
  });
}
