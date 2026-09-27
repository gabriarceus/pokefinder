part of 'detail_bloc.dart';

@immutable
sealed class PokemonBlocState extends Equatable {
  const PokemonBlocState();
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
    this.failedForm,
  });

  static const _unset = Object();

  final Pokemon pokemon;
  final PokemonFormDetails? selectedFormDetails;
  final List<PokemonEncounter>? encounters;
  final bool isLoadingForm;
  final bool isLoadingEncounters;
  final PokemonFailure? formFailure;
  final PokemonFailure? encountersFailure;
  final PokemonForm? failedForm;

  /// Active form details, falling back to the base Pokémon when no alternate
  /// form has been selected.
  PokemonFormDetails get formDetails =>
      selectedFormDetails ?? PokemonFormDetails.fromPokemon(pokemon);

  /// Summary of the displayed form, keyed by the form's own identity so that
  /// favouriting or viewing an alternate form never collides with its base
  /// species. Types and the form lineage come from the base Pokémon.
  PokemonSummary get summary {
    final form = formDetails;
    final types = form.type1 != null
        ? [form.type1, form.type2]
        : [pokemon.type1, pokemon.type2];
    return PokemonSummary(
      id: form.id,
      name: form.name,
      spriteUrl: form.artworkDefault.isNotEmpty
          ? form.artworkDefault
          : pokemon.sprite,
      types: types.whereType<PokemonType>().toList(),
      parentSpeciesId: PokemonFormClassifier.resolveParentSpeciesId(
        pokemon.name,
        id: pokemon.id,
      ),
      parentSpeciesName: pokemon.speciesName,
      formCategory: PokemonFormClassifier.classifyCategory(
        form.name,
        id: form.id,
      ),
      regionalGroup: PokemonFormClassifier.resolveRegionalGroup(form.name),
    );
  }

  PokemonBlocSuccess copyWith({
    Pokemon? pokemon,
    PokemonFormDetails? selectedFormDetails,
    List<PokemonEncounter>? encounters,
    bool? isLoadingForm,
    bool? isLoadingEncounters,
    Object? formFailure = _unset,
    Object? encountersFailure = _unset,
    Object? failedForm = _unset,
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
      failedForm: identical(failedForm, _unset)
          ? this.failedForm
          : failedForm as PokemonForm?,
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
    failedForm,
  ];
}
