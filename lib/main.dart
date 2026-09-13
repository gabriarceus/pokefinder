import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/bootstrap/mobile_storage_initializer.dart';

void main() {
  bootstrap(then: () => const MyApp());
}

/// Executes mobile application startup with isolated storage initialization.
///
/// If storage or dependency setup fails, renders [StartupErrorApp] with a retry action
/// instead of crashing before the first frame renders.
Future<void> bootstrap({
  required Widget Function() then,
  Future<void> Function()? initializeStorage,
  void Function(Widget)? appRunner,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final run = appRunner ?? runApp;

  try {
    if (initializeStorage != null) {
      await initializeStorage();
    } else {
      await initializeMobileStorage();
    }

    await configureDependencies(Environment.prod);
    run(then());
  } catch (error) {
    run(
      StartupErrorApp(
        onRetry: () => bootstrap(
          then: then,
          initializeStorage: initializeStorage,
          appRunner: appRunner,
        ),
        errorMessage: kDebugMode ? error.toString() : null,
      ),
    );
  }
}

/// The main app root widget.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp] with an optional [router] override.
  const MyApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        if (getIt.isRegistered<PreferencesCubit>())
          BlocProvider.value(value: getIt<PreferencesCubit>()),
        if (getIt.isRegistered<LanguageCubit>())
          BlocProvider.value(value: getIt<LanguageCubit>()),
        if (getIt.isRegistered<FavoritesCubit>())
          BlocProvider.value(value: getIt<FavoritesCubit>()),
        if (getIt.isRegistered<RecentHistoryCubit>())
          BlocProvider.value(value: getIt<RecentHistoryCubit>()),
      ],
      child: BlocBuilder<PreferencesCubit, PreferencesState>(
        builder: (context, prefState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return MaterialApp.router(
                routerConfig: router ?? appRouter,
                themeMode: prefState.themeMode,
                theme: AppPalette.lightTheme,
                darkTheme: AppPalette.darkTheme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: langState.locale,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
