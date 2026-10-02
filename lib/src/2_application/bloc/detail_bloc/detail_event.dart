part of 'detail_bloc.dart';

@immutable
abstract class PokemonDetailEvent {}

class FetchPokemonEvent extends PokemonDetailEvent {
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

class SelectPokemonFormEvent extends PokemonDetailEvent {
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

class RetryPokemonEncountersEvent extends PokemonDetailEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetryPokemonEncountersEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ClearPokemonFormFailureEvent extends PokemonDetailEvent {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClearPokemonFormFailureEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
