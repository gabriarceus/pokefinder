import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

/// State of a one-shot load of a [T]: loading, loaded or failed.
@immutable
sealed class LoadState<T> extends Equatable {
  const LoadState();

  @override
  List<Object?> get props => [];
}

final class LoadInProgress<T> extends LoadState<T> {
  const LoadInProgress();
}

final class LoadSuccess<T> extends LoadState<T> {
  const LoadSuccess(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class LoadFailure<T> extends LoadState<T> {
  const LoadFailure(this.failure);

  final PokemonFailure failure;

  @override
  List<Object?> get props => [failure];
}
