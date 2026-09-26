import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Loading page of the detail screen, with a back button.
class DetailLoading extends StatelessWidget {
  const DetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SpinKitPouringHourGlassRefined(
              color: Theme.of(context).colorScheme.primary,
              size: 50.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).loading),
        ],
      ),
    );
  }
}
