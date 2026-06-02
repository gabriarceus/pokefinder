part of 'detail_bloc.dart';

@immutable
abstract class PokemonBlocEvent {}

class FetchPokemonEvent extends PokemonBlocEvent {
  FetchPokemonEvent(this.pokemonName);

  final String pokemonName;
}

class SelectPokemonFormEvent extends PokemonBlocEvent {
  SelectPokemonFormEvent(this.form);

  final PokemonForm form;
}

class ClearPokemonEvent extends PokemonBlocEvent {}
