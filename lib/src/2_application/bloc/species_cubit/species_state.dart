import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_species.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

@immutable
sealed class SpeciesState extends Equatable {
  const SpeciesState();

  @override
  List<Object?> get props => [];
}

final class SpeciesInitial extends SpeciesState {
  const SpeciesInitial();
}

final class SpeciesLoading extends SpeciesState {
  const SpeciesLoading();
}

final class SpeciesLoaded extends SpeciesState {
  const SpeciesLoaded(this.species);

  final PokemonSpecies species;

  @override
  List<Object?> get props => [species];
}

final class SpeciesError extends SpeciesState {
  const SpeciesError(this.message, {this.failure});

  final String message;
  final PokemonFailure? failure;

  @override
  List<Object?> get props => [message, failure];
}
