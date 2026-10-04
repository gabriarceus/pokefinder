part of 'detail_bloc.dart';

@immutable
sealed class PokemonDetailState extends Equatable {
  const PokemonDetailState();
}

final class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();

  @override
  List<Object?> get props => [];
}

final class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();

  @override
  List<Object?> get props => [];
}

final class PokemonDetailFailure extends PokemonDetailState {
  const PokemonDetailFailure(this.failure);

  final PokemonFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class PokemonDetailSuccess extends PokemonDetailState {
  const PokemonDetailSuccess({
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

  /// Active form details, falling back to the loaded Pokémon's attributes.
  PokemonFormDetails get formDetails =>
      selectedFormDetails ?? PokemonFormDetails.fromPokemon(pokemon);

  /// Summary of the active Pokémon, including its exact identity and lineage.
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

  PokemonDetailSuccess copyWith({
    Pokemon? pokemon,
    PokemonFormDetails? selectedFormDetails,
    List<PokemonEncounter>? encounters,
    bool? isLoadingForm,
    bool? isLoadingEncounters,
    Object? formFailure = _unset,
    Object? encountersFailure = _unset,
    Object? failedForm = _unset,
  }) {
    return PokemonDetailSuccess(
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
