import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockGetCacheSizeUseCase extends Mock implements GetCacheSizeUseCase {}

class _MockClearCacheUseCase extends Mock implements ClearCacheUseCase {}

void main() {
  late _MockEnLogger logger;
  late _MockGetCacheSizeUseCase getCacheSizeUseCase;
  late _MockClearCacheUseCase clearCacheUseCase;
  late InMemoryHydratedStorage storage;

  setUp(() {
    logger = _MockEnLogger();
    getCacheSizeUseCase = _MockGetCacheSizeUseCase();
    clearCacheUseCase = _MockClearCacheUseCase();
    storage = InMemoryHydratedStorage();
    HydratedBloc.storage = storage;
  });

  PreferencesCubit buildCubit() {
    return PreferencesCubit(logger, getCacheSizeUseCase, clearCacheUseCase);
  }

  group('PreferencesCubit', () {
    test('initial state defaults correctly', () {
      final cubit = buildCubit();
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(cubit.state.unitSystem, UnitSystem.metric);
      expect(cubit.state.autoPlayCry, isFalse);
      expect(cubit.state.cryVolume, equals(1.0));
      expect(cubit.state.cacheSizeBytes, equals(0));
    });

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

    test('refreshCacheSize updates cacheSizeBytes from use case', () async {
      when(
        () => getCacheSizeUseCase(),
      ).thenAnswer((_) async => const Right(2048));

      final cubit = buildCubit();
      await cubit.refreshCacheSize();

      expect(cubit.state.cacheSizeBytes, equals(2048));
      verify(() => getCacheSizeUseCase()).called(1);
    });

    test(
      'clearCache invokes clearCacheUseCase and refreshes cache size',
      () async {
        when(
          () => clearCacheUseCase(),
        ).thenAnswer((_) async => const Right(unit));
        when(
          () => getCacheSizeUseCase(),
        ).thenAnswer((_) async => const Right(0));

        final cubit = buildCubit();
        await cubit.clearCache();

        expect(cubit.state.cacheSizeBytes, equals(0));
        verify(() => clearCacheUseCase()).called(1);
      },
    );

    test('persists state across cubit restarts', () async {
      when(() => getCacheSizeUseCase()).thenAnswer((_) async => const Right(0));
      when(
        () => clearCacheUseCase(),
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
