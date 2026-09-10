part of 'detail_bloc.dart';

@immutable
abstract class PokemonBlocEvent {}

class FetchPokemonEvent extends PokemonBlocEvent {
  FetchPokemonEvent(this.pokemonName);

  final String pokemonName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchPokemonEvent &&
          runtimeType == other.runtimeType &&
          pokemonName == other.pokemonName;

  @override
  int get hashCode => pokemonName.hashCode;
}

class SelectPokemonFormEvent extends PokemonBlocEvent {
  SelectPokemonFormEvent(this.form);

  final PokemonForm form;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectPokemonFormEvent &&
          runtimeType == other.runtimeType &&
          form == other.form;

  @override
  int get hashCode => form.hashCode;
}

class RetryPokemonEncountersEvent extends PokemonBlocEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryPokemonEncountersEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ClearPokemonFormFailureEvent extends PokemonBlocEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClearPokemonFormFailureEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
