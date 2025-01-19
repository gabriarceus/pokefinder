import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/bloc_detail/detail_bloc_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                'Error: ${state.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: Text(
                  AppLocalizations.of(context)!.backButton,
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
            'assets/images/sad_azurill.png',
            scale: 2,
          ),
        ),
      ],
    );
  }
}
