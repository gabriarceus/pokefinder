part of 'detail_bloc.dart';

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

final class PokemonBlocInitial extends PokemonBlocState {}

final class PokemonBlocLoading extends PokemonBlocState {}

final class PokemonBlocFailure extends PokemonBlocState {
  PokemonBlocFailure(this.error);

  final String error;
}

final class PokemonBlocSuccess extends PokemonBlocState {
  PokemonBlocSuccess({
    required this.pokemon,
    this.selectedFormDetails,
    this.encounters,
    this.isLoadingForm = false,
    this.isLoadingEncounters = false,
    this.formError,
    this.encountersError,
  });

  final Pokemon pokemon;
  final PokemonFormDetails? selectedFormDetails;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingForm;
  final bool isLoadingEncounters;
  final String? formError;
  final String? encountersError;

  PokemonBlocSuccess copyWith({
    Pokemon? pokemon,
    PokemonFormDetails? selectedFormDetails,
    List<PokemonEncounter>? encounters,
    bool? isLoadingForm,
    bool? isLoadingEncounters,
    String? formError,
    String? encountersError,
  }) {
    return PokemonBlocSuccess(
      pokemon: pokemon ?? this.pokemon,
      selectedFormDetails: selectedFormDetails ?? this.selectedFormDetails,
      encounters: encounters ?? this.encounters,
      isLoadingForm: isLoadingForm ?? this.isLoadingForm,
      isLoadingEncounters: isLoadingEncounters ?? this.isLoadingEncounters,
      formError: formError ?? this.formError,
      encountersError: encountersError ?? this.encountersError,
    );
  }
}

