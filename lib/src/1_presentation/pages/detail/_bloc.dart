import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';

/// Provides a [PokemonDetailBloc] scoped to [pokemonName] and loads its data.
class PokemonDetailBlocProvider extends StatelessWidget {
  const PokemonDetailBlocProvider({
    super.key,
    required this.child,
    required this.pokemonName,
  });

  final String pokemonName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(pokemonName),
      create: (_) => createPokemonDetailBloc(pokemonName),
      child: child,
    );
  }
}
