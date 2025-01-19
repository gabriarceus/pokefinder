part of 'detail_bloc_bloc.dart';

@immutable
abstract class PokemonBlocEvent {}

//Gli eventi possibili della business logic
class FetchPokemonEvent extends PokemonBlocEvent {
  final String pokemonName;

  FetchPokemonEvent(this.pokemonName);
}

class ClearPokemonEvent extends PokemonBlocEvent {}