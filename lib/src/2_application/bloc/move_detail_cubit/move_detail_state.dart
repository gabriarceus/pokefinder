import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

sealed class MoveDetailState extends Equatable {
  const MoveDetailState();

  @override
  List<Object?> get props => [];
}

final class MoveDetailInitial extends MoveDetailState {}

final class MoveDetailLoading extends MoveDetailState {}

final class MoveDetailLoaded extends MoveDetailState {
  const MoveDetailLoaded(this.moveDetail);
  final MoveDetail moveDetail;

  @override
  List<Object?> get props => [moveDetail];
}

final class MoveDetailError extends MoveDetailState {
  const MoveDetailError(this.message, {this.failure});
  final String message;
  final PokemonFailure? failure;

  @override
  List<Object?> get props => [message, failure];
}
