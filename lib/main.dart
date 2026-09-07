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
    return BlocProvider(
      create: (_) => getIt<LanguageCubit>(),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: router ?? appRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: state.locale,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
