import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import 'in_memory_hydrated_storage.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

/// The six app-lifetime cubits that `MyApp` provides at the app root.
///
/// Every cubit left out of the constructor is a fresh real instance with a
/// mock logger. The default [ComparisonCubit] and [PreferencesCubit] use a
/// repository that answers every call with a [NetworkUnavailableFailure].
/// Hydrated cubits need [HydratedBloc.storage]: the constructor sets an
/// [InMemoryHydratedStorage] when none is set.
class TestAppCubits {
  TestAppCubits({
    PreferencesCubit? preferences,
    LanguageCubit? language,
    FavoritesCubit? favorites,
    RecentHistoryCubit? recentHistory,
    ComparisonCubit? comparison,
    TeamsCubit? teams,
  }) {
    ensureHydratedStorage();
    final logger = _MockEnLogger();
    this.preferences =
        preferences ?? PreferencesCubit(logger, _offlineRepository());
    this.language = language ?? LanguageCubit(logger);
    this.favorites = favorites ?? FavoritesCubit(logger);
    this.recentHistory = recentHistory ?? RecentHistoryCubit(logger);
    this.comparison =
        comparison ?? ComparisonCubit(logger, _offlineRepository());
    this.teams = teams ?? TeamsCubit(logger);
  }

  late final PreferencesCubit preferences;
  late final LanguageCubit language;
  late final FavoritesCubit favorites;
  late final RecentHistoryCubit recentHistory;
  late final ComparisonCubit comparison;
  late final TeamsCubit teams;

  static IPokemonRepository _offlineRepository() {
    registerFallbackValue(PokemonName('bulbasaur'));
    final repository = _MockPokemonRepository();
    const offline = NetworkUnavailableFailure('offline');
    when(
      () => repository.getPokemon(any()),
    ).thenAnswer((_) async => left(offline));
    when(() => repository.getCacheSize()).thenAnswer((_) async => right(0));
    return repository;
  }

  /// Wraps [child] in a provider for each cubit.
  Widget provide(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: preferences),
        BlocProvider.value(value: language),
        BlocProvider.value(value: favorites),
        BlocProvider.value(value: recentHistory),
        BlocProvider.value(value: comparison),
        BlocProvider.value(value: teams),
      ],
      child: child,
    );
  }

  /// Closes every cubit.
  Future<void> close() async {
    await preferences.close();
    await language.close();
    await favorites.close();
    await recentHistory.close();
    await comparison.close();
    await teams.close();
  }
}

extension PumpApp on WidgetTester {
  /// Pumps [home], or the screen [router] points to, inside the app shell:
  /// the app cubits, the app themes and the localizations for [locale].
  ///
  /// Uses [cubits] when given; otherwise builds a [TestAppCubits] and closes
  /// it at the end of the test. [builder] is passed to the `MaterialApp`, for
  /// example to override the `MediaQuery`. Pumps one frame; settling is up to
  /// the test.
  Future<void> pumpApp({
    Widget? home,
    GoRouter? router,
    TestAppCubits? cubits,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    TransitionBuilder? builder,
  }) async {
    assert(
      (home == null) != (router == null),
      'Pass exactly one of home or router.',
    );
    final appCubits = cubits ?? TestAppCubits();
    if (cubits == null) addTearDown(appCubits.close);

    const delegates = AppLocalizations.localizationsDelegates;
    const locales = AppLocalizations.supportedLocales;
    final app = router != null
        ? MaterialApp.router(
            routerConfig: router,
            theme: AppPalette.lightTheme,
            darkTheme: AppPalette.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: delegates,
            supportedLocales: locales,
            locale: locale,
            builder: builder,
          )
        : MaterialApp(
            home: home,
            theme: AppPalette.lightTheme,
            darkTheme: AppPalette.darkTheme,
            themeMode: themeMode,
            localizationsDelegates: delegates,
            supportedLocales: locales,
            locale: locale,
            builder: builder,
          );
    await pumpWidget(appCubits.provide(app));
  }
}
