import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/settings/settings_page.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockEnLogger logger;
  late _MockPokemonRepository repository;
  late PreferencesCubit preferencesCubit;
  late RecentHistoryCubit recentHistoryCubit;
  late LanguageCubit languageCubit;

  setUp(() {
    HydratedBloc.storage = InMemoryHydratedStorage();
    logger = _MockEnLogger();
    repository = _MockPokemonRepository();

    when(
      () => repository.getCacheSize(),
    ).thenAnswer((_) async => const Right(1500000));
    when(
      () => repository.clearCache(),
    ).thenAnswer((_) async => const Right(unit));

    preferencesCubit = PreferencesCubit(logger, repository);
    recentHistoryCubit = RecentHistoryCubit(logger);
    languageCubit = LanguageCubit(logger);
  });

  tearDown(() {
    preferencesCubit.close();
    recentHistoryCubit.close();
    languageCubit.close();
  });

  Widget buildSettingsWidget(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;

    return MultiBlocProvider(
      providers: [
        BlocProvider<PreferencesCubit>.value(value: preferencesCubit),
        BlocProvider<RecentHistoryCubit>.value(value: recentHistoryCubit),
        BlocProvider<LanguageCubit>.value(value: languageCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SettingsPage(),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('renders all preference sections', (tester) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Measurement Units'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Recently Viewed'), findsOneWidget);
      expect(find.text('Storage & Cache'), findsOneWidget);
      expect(find.text('About PokéFinder'), findsWidgets);
    });

    testWidgets('changes theme mode via segmented button', (tester) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.themeMode, ThemeMode.system);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(preferencesCubit.state.themeMode, ThemeMode.light);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(preferencesCubit.state.themeMode, ThemeMode.dark);
    });

    testWidgets('changes unit system via segmented button', (tester) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.unitSystem, UnitSystem.metric);

      await tester.tap(find.text('Imperial (ft, lbs)'));
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.unitSystem, UnitSystem.imperial);
    });

    testWidgets('toggles auto-play cry and updates volume slider', (
      tester,
    ) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(preferencesCubit.state.autoPlayCry, isFalse);

      // Toggle switch
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Auto-play cry on open'),
      );
      await tester.pumpAndSettle();
      expect(preferencesCubit.state.autoPlayCry, isTrue);

      // Adjust volume slider
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      await tester.tap(sliderFinder);
      await tester.pumpAndSettle();
      expect(preferencesCubit.state.cryVolume, isNotNull);
    });

    testWidgets('toggles keep history switch', (tester) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(recentHistoryCubit.state.isHistoryEnabled, isTrue);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Keep history'));
      await tester.pumpAndSettle();

      expect(recentHistoryCubit.state.isHistoryEnabled, isFalse);
    });

    testWidgets('clearing history opens dialog and clears on confirm', (
      tester,
    ) async {
      recentHistoryCubit.addRecentSearch('pikachu');
      recentHistoryCubit.addRecentPokemon(
        const PokemonSummary(
          id: 25,
          name: 'pikachu',
          spriteUrl: '',
          types: [PokemonType.electric],
        ),
      );

      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      // Tap Clear history tile
      await tester.tap(find.widgetWithText(ListTile, 'Clear history'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Are you sure you want to clear your search and viewing history?',
        ),
        findsOneWidget,
      );

      // Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(recentHistoryCubit.state.recentSearches, isNotEmpty);

      // Tap again and confirm
      await tester.tap(find.widgetWithText(ListTile, 'Clear history'));
      await tester.pumpAndSettle();
      final dialogClearButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Clear'),
      );
      await tester.tap(dialogClearButton);
      await tester.pumpAndSettle();

      expect(recentHistoryCubit.state.recentSearches, isEmpty);
      expect(recentHistoryCubit.state.recentPokemon, isEmpty);
    });

    testWidgets('changes language via the segmented button', (tester) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      expect(languageCubit.state.languageId, Language.system.id);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(languageCubit.state.languageId, Language.english.id);

      await tester.tap(find.text('Italiano'));
      await tester.pumpAndSettle();
      expect(languageCubit.state.languageId, Language.italian.id);

      await tester.tap(find.text('System').last);
      await tester.pumpAndSettle();
      expect(languageCubit.state.languageId, Language.system.id);
    });

    testWidgets('displays cache size and clearing cache hits the repository', (
      tester,
    ) async {
      await tester.pumpWidget(buildSettingsWidget(tester));
      await tester.pumpAndSettle();

      // Post-frame callback triggers refreshCacheSize
      verify(() => repository.getCacheSize()).called(1);
      expect(find.textContaining('1.4 MB'), findsOneWidget);

      // Open clear cache dialog
      final clearButtons = find.widgetWithText(FilledButton, 'Clear');
      await tester.tap(clearButtons.first);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Are you sure you want to clear the cache? Downloaded data and images will need to be reloaded.',
        ),
        findsOneWidget,
      );

      // Confirm clear
      final confirmDialogButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Clear'),
      );
      await tester.tap(confirmDialogButton);
      await tester.pumpAndSettle();

      verify(() => repository.clearCache()).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Cache cleared successfully'), findsOneWidget);
    });
  });
}
