import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';

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
  const MoveDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
