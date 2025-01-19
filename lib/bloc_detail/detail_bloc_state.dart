part of 'detail_bloc_bloc.dart';

@immutable
sealed class PokemonBlocState {
  T map<T>({
    required T Function(PokemonBlocInitial state) onInitial,
    required T Function(PokemonBlocLoading state) onLoading,
    required T Function(PokemonBlocFailure state) onFailure,
    required T Function(PokemonBlocSuccess state) onSuccess,
  }) {
    switch (this) {
      case PokemonBlocInitial initial:
        return onInitial(initial);
      case PokemonBlocLoading loading:
        return onLoading(loading);

      case PokemonBlocFailure failure:
        return onFailure(failure);

      case PokemonBlocSuccess success:
        return onSuccess(success);
    }
  }
}

//Gli stati possibili della business logic
final class PokemonBlocInitial extends PokemonBlocState {}

final class PokemonBlocLoading extends PokemonBlocState {}

final class PokemonBlocFailure extends PokemonBlocState {
  PokemonBlocFailure(this.error);

  final String error;
}

final class PokemonBlocSuccess extends PokemonBlocState {
  final Pokemon pokemon;

  PokemonBlocSuccess(this.pokemon);
}
