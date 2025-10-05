part of 'detail_bloc.dart';

@immutable
abstract class PokemonBlocEvent {}

class FetchPokemonEvent extends PokemonBlocEvent {
  final String pokemonName;

  FetchPokemonEvent(this.pokemonName);
}

class ClearPokemonEvent extends PokemonBlocEvent {}
