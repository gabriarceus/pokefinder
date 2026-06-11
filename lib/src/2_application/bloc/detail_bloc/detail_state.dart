part of 'detail_bloc.dart';

@immutable
sealed class PokemonBlocState extends Equatable {
  const PokemonBlocState();

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

final class PokemonBlocInitial extends PokemonBlocState {
  const PokemonBlocInitial();

  @override
  List<Object?> get props => [];
}

final class PokemonBlocLoading extends PokemonBlocState {
  const PokemonBlocLoading();

  @override
  List<Object?> get props => [];
}

final class PokemonBlocFailure extends PokemonBlocState {
  const PokemonBlocFailure(this.failure);

  final PokemonFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class PokemonBlocSuccess extends PokemonBlocState {
  const PokemonBlocSuccess({
    required this.pokemon,
    this.selectedFormDetails,
    this.encounters,
    this.isLoadingForm = false,
    this.isLoadingEncounters = false,
    this.formFailure,
    this.encountersFailure,
  });

  static const _unset = Object();

  final Pokemon pokemon;
  final PokemonFormDetails? selectedFormDetails;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingForm;
  final bool isLoadingEncounters;
  final PokemonFailure? formFailure;
  final PokemonFailure? encountersFailure;

  /// Active form details, falling back to the base Pokémon when no alternate
  /// form has been selected.
  PokemonFormDetails get formDetails =>
      selectedFormDetails ?? PokemonFormDetails.fromPokemon(pokemon);

  PokemonBlocSuccess copyWith({
    Pokemon? pokemon,
    PokemonFormDetails? selectedFormDetails,
    List<PokemonEncounter>? encounters,
    bool? isLoadingForm,
    bool? isLoadingEncounters,
    Object? formFailure = _unset,
    Object? encountersFailure = _unset,
  }) {
    return PokemonBlocSuccess(
      pokemon: pokemon ?? this.pokemon,
      selectedFormDetails: selectedFormDetails ?? this.selectedFormDetails,
      encounters: encounters ?? this.encounters,
      isLoadingForm: isLoadingForm ?? this.isLoadingForm,
      isLoadingEncounters: isLoadingEncounters ?? this.isLoadingEncounters,
      formFailure: identical(formFailure, _unset)
          ? this.formFailure
          : formFailure as PokemonFailure?,
      encountersFailure: identical(encountersFailure, _unset)
          ? this.encountersFailure
          : encountersFailure as PokemonFailure?,
    );
  }

  @override
  List<Object?> get props => [
        pokemon,
        selectedFormDetails,
        encounters,
        isLoadingForm,
        isLoadingEncounters,
        formFailure,
        encountersFailure,
      ];
}
