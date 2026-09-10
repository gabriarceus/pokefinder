import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/move_detail_bottom_sheet.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockPokemonRepository repository;
  late _MockEnLogger logger;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<IPokemonRepository>()) {
      getIt.unregister<IPokemonRepository>();
    }
    if (getIt.isRegistered<EnLogger>()) {
      getIt.unregister<EnLogger>();
    }
    if (getIt.isRegistered<MoveDetailCubit>()) {
      getIt.unregister<MoveDetailCubit>();
    }
    getIt.registerSingleton<IPokemonRepository>(repository);
    getIt.registerSingleton<EnLogger>(logger);
    getIt.registerFactory<MoveDetailCubit>(
      () => MoveDetailCubit(repository, logger),
    );
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MoveDetailCubit>()) {
      getIt.unregister<MoveDetailCubit>();
    }
    if (getIt.isRegistered<IPokemonRepository>()) {
      getIt.unregister<IPokemonRepository>();
    }
    if (getIt.isRegistered<EnLogger>()) {
      getIt.unregister<EnLogger>();
    }
  });

  testWidgets(
    'MoveDetailBottomSheet renders error message and retry button on failure',
    (tester) async {
      const failure = NetworkUnavailableFailure();
      when(
        () => repository.getMoveDetail('tackle'),
      ).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MoveDetailBottomSheet(
              moveName: 'tackle',
              capitalizedName: 'Tackle',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error message is rendered
      expect(
        find.text('No internet connection. Please check your network.'),
        findsOneWidget,
      );

      // Verify Retry button is rendered and tapping it calls getMoveDetail again
      final retryFinder = find.widgetWithText(OutlinedButton, 'Retry');
      expect(retryFinder, findsOneWidget);
      await tester.tap(retryFinder);
      await tester.pumpAndSettle();

      verify(() => repository.getMoveDetail('tackle')).called(2);
    },
  );
}
