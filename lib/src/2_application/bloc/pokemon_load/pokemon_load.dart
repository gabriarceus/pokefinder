import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Loading state of the details of one Pokémon.
sealed class PokemonLoad extends Equatable {
  const PokemonLoad();

  @override
  List<Object?> get props => [];
}

final class PokemonLoading extends PokemonLoad {
  const PokemonLoading();
}

final class PokemonLoaded extends PokemonLoad {
  const PokemonLoaded(this.pokemon);

  final Pokemon pokemon;

  @override
  List<Object?> get props => [pokemon];
}

final class PokemonLoadFailed extends PokemonLoad {
  const PokemonLoadFailed(this.failure);

  final PokemonFailure failure;

  @override
  List<Object?> get props => [failure];
}
