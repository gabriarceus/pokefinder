import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/ability_detail_bottom_sheet.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class MockGetAbilityDetailUseCase extends Mock
    implements GetAbilityDetailUseCase {}

void main() {
  late MockGetAbilityDetailUseCase mockGetAbilityDetailUseCase;

  setUpAll(() async {
    await configureDependencies('mock');
    registerFallbackValue(CancellationToken());
  });

  setUp(() {
    mockGetAbilityDetailUseCase = MockGetAbilityDetailUseCase();
    if (getIt.isRegistered<AbilityDetailCubit>()) {
      getIt.unregister<AbilityDetailCubit>();
    }
    getIt.registerFactory<AbilityDetailCubit>(
      () => AbilityDetailCubit(mockGetAbilityDetailUseCase, getIt<EnLogger>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<AbilityDetailCubit>()) {
      getIt.unregister<AbilityDetailCubit>();
    }
    getIt.registerFactory<AbilityDetailCubit>(
      () => AbilityDetailCubit(
        getIt<GetAbilityDetailUseCase>(),
        getIt<EnLogger>(),
      ),
    );
  });

  Widget createTestWidget({required String abilityName}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => AbilityDetailBottomSheet.show(
                context,
                abilityName: abilityName,
                displayName: abilityName.isNotEmpty
                    ? '${abilityName[0].toUpperCase()}${abilityName.substring(1)}'
                    : abilityName,
              ),
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );
  }

  group('AbilityDetailBottomSheet Widget Tests', () {
    testWidgets('shows loading indicator and then displays ability info', (
      tester,
    ) async {
      when(
        () => mockGetAbilityDetailUseCase(
          'overgrow',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          AbilityDetail(
            id: 65,
            name: 'overgrow',
            flavorTexts: {'en': 'Ups GRASS moves in a pinch.'},
            effects: {
              'en':
                  'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× damage.',
            },
            shortEffects: {
              'en':
                  'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
            },
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(abilityName: 'overgrow'));
      await tester.tap(find.text('Open Sheet'));
      await tester.pump(); // Start opening sheet

      expect(find.byType(AbilityDetailBottomSheet), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Overgrow'), findsOneWidget);
      expect(
        find.text(
          'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× damage.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows error state and retries on tap', (tester) async {
      when(
        () => mockGetAbilityDetailUseCase(
          'chlorophyll',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left(ServerFailure(500, 'Failed to load ability details.')),
      );

      await tester.pumpWidget(createTestWidget(abilityName: 'chlorophyll'));
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // Reset mock for successful retry
      when(
        () => mockGetAbilityDetailUseCase(
          'chlorophyll',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          AbilityDetail(
            id: 34,
            name: 'chlorophyll',
            flavorTexts: {'en': 'Raises SPEED in sunshine.'},
            effects: {
              'en': 'During strong sunlight, this Pokémon’s Speed is doubled.',
            },
            shortEffects: {'en': 'Doubles Speed during strong sunlight.'},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Chlorophyll'), findsOneWidget);
      expect(
        find.text('Doubles Speed during strong sunlight.'),
        findsOneWidget,
      );
    });
  });
}
