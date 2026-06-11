import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/2_application/application.dart';

const _kSadAzurillAsset = 'assets/images/sad_azurill.png';

class DetailFailure extends StatelessWidget {
  const DetailFailure({
    super.key,
    required this.state,
  });

  final PokemonBlocFailure state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.failure.localizedMessage(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: Text(
                  AppLocalizations.of(context).backButton,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            _kSadAzurillAsset,
            scale: 2,
          ),
        ),
      ],
    );
  }
}
