import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_summary.dart';

/// Lightweight history record for a viewed Pokémon.
class RecentPokemon extends Equatable {
  const RecentPokemon({required this.pokemon, required this.viewedAt});

  /// Deserializes an entity from a JSON map.
  factory RecentPokemon.fromJson(Map<String, dynamic> json) {
    return RecentPokemon(
      pokemon: PokemonSummary.fromJson(json),
      viewedAt:
          DateTime.tryParse(json['viewedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final PokemonSummary pokemon;

  /// Timestamp when the entry was last viewed.
  final DateTime viewedAt;

  /// Serializes this entity to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    ...pokemon.toJson(),
    'viewedAt': viewedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [pokemon, viewedAt];
}
