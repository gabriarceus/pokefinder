import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Standalone fallback application shown when storage or dependency bootstrap fails.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.onRetry, this.errorMessage});

  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StartupErrorPage(onRetry: onRetry, errorMessage: errorMessage),
    );
  }
}

/// Content page for application bootstrap failure with a retry action.
class StartupErrorPage extends StatelessWidget {
  const StartupErrorPage({super.key, required this.onRetry, this.errorMessage});

  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.startupErrorTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? l10n.startupErrorMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
