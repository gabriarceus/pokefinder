import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/entities/evolution_chain.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

@immutable
sealed class EvolutionState extends Equatable {
  const EvolutionState();

  @override
  List<Object?> get props => [];
}

final class EvolutionInitial extends EvolutionState {
  const EvolutionInitial();
}

final class EvolutionLoading extends EvolutionState {
  const EvolutionLoading();
}

final class EvolutionLoaded extends EvolutionState {
  const EvolutionLoaded(this.chain);

  final EvolutionChain chain;

  @override
  List<Object?> get props => [chain];
}

final class EvolutionError extends EvolutionState {
  const EvolutionError(this.message, {this.failure});

  final String message;
  final PokemonFailure? failure;

  @override
  List<Object?> get props => [message, failure];
}
