import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';

const _kSadAzurillAsset = 'assets/images/sad_azurill.png';

/// Fallback screen rendered when a route does not exist or route parameters are malformed.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, this.rawParam, this.errorMessage});

  final String? rawParam;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routeNotFoundTitle),
        backgroundColor: AppPalette.brandRed,
        foregroundColor: AppPalette.onBrandRed,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: AppPalette.brandRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.routeNotFoundTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage ?? l10n.routeNotFoundMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.brandRed,
                      foregroundColor: AppPalette.onBrandRed,
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.goHome),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(_kSadAzurillAsset, scale: 2),
            ),
          ),
        ],
      ),
    );
  }
}
