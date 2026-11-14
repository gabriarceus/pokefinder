import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_summary.dart';

/// Available sorting strategies for favorited Pokémon.
enum FavoriteSortOrder {
  /// Sort by Pokédex ID ascending (lowest first).
  idAscending,

  /// Sort by Pokédex ID descending (highest first).
  idDescending,

  /// Sort alphabetically by name (A to Z).
  nameAscending,

  /// Sort reverse alphabetically by name (Z to A).
  nameDescending,

  /// Sort by date added descending (newest first).
  recentlyAdded,
}

/// Lightweight bookmark entity for a favorited Pokémon.
class FavoritePokemon extends Equatable {
  const FavoritePokemon({required this.pokemon, required this.addedAt});

  /// Deserializes an entity from a JSON map.
  factory FavoritePokemon.fromJson(Map<String, dynamic> json) {
    return FavoritePokemon(
      pokemon: PokemonSummary.fromJson(json),
      addedAt:
          DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final PokemonSummary pokemon;

  /// Timestamp when the entry was added to favorites.
  final DateTime addedAt;

  /// Serializes this entity to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    ...pokemon.toJson(),
    'addedAt': addedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [pokemon, addedAt];
}
