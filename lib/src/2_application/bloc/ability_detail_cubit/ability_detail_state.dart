import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

@immutable
sealed class AbilityDetailState extends Equatable {
  const AbilityDetailState();

  @override
  List<Object?> get props => [];
}

final class AbilityDetailInitial extends AbilityDetailState {
  const AbilityDetailInitial();
}

final class AbilityDetailLoading extends AbilityDetailState {
  const AbilityDetailLoading();
}

final class AbilityDetailLoaded extends AbilityDetailState {
  const AbilityDetailLoaded(this.abilityDetail);

  final AbilityDetail abilityDetail;

  @override
  List<Object?> get props => [abilityDetail];
}

final class AbilityDetailError extends AbilityDetailState {
  const AbilityDetailError(this.message, {this.failure});

  final String message;
  final PokemonFailure? failure;

  @override
  List<Object?> get props => [message, failure];
}
