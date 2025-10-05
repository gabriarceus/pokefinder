import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

class DetailLoading extends StatelessWidget {
  const DetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(child: spinkit),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).loading),
      ],
    );
  }
}

const spinkit = SpinKitPouringHourGlassRefined(
  color: Colors.red,
  size: 50.0,
);
