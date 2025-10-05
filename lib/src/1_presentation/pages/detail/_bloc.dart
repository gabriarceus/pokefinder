import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/bootstrap.dart';

class PokemonBlocProvider extends StatelessWidget {
  /// inject [PokemonBloc]
  ///
  /// on init add [FetchPokemonEvent]
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
      create: (_) => getIt<PokemonBloc>()..add(FetchPokemonEvent(pokemonName)),
      child: child,
    );
  }
}

class PokemonBlocBuilder extends StatelessWidget {
  const PokemonBlocBuilder({
    super.key,
    required this.onInitial,
    required this.onLoading,
    required this.onFailure,
    required this.onSuccess,
  });

  final Widget Function(BuildContext context, PokemonBlocInitial state)
      onInitial;
  final Widget Function(BuildContext context, PokemonBlocLoading state)
      onLoading;
  final Widget Function(BuildContext context, PokemonBlocFailure state)
      onFailure;
  final Widget Function(BuildContext context, PokemonBlocSuccess state)
      onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonBloc, PokemonBlocState>(
      builder: (context, state) {
        return state.map(
          onInitial: (initial) => onInitial(context, initial),
          onLoading: (loading) => onLoading(context, loading),
          onFailure: (failure) => onFailure(context, failure),
          onSuccess: (success) => onSuccess(context, success),
        );
      },
    );
  }
}
