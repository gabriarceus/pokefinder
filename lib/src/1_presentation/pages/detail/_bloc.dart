import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';

/// Provides a [PokemonDetailBloc] to [child] and starts loading [pokemonName].
class PokemonBlocProvider extends StatelessWidget {
  const PokemonBlocProvider({
    super.key,
    required this.child,
    required this.pokemonName,
  });

  final String pokemonName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createPokemonBloc(pokemonName),
      child: child,
    );
  }
}
