import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

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
  const FavoritePokemon({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
    required this.addedAt,
  });

  /// Pokédex identifier.
  final int id;

  /// Canonical name of the Pokémon.
  final String name;

  /// URL of the default sprite image.
  final String spriteUrl;

  /// Pokémon elemental types.
  final List<PokemonType> types;

  /// Timestamp when the entry was added to favorites.
  final DateTime addedAt;

  /// Serializes this entity to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spriteUrl': spriteUrl,
    'types': types.map((t) => t.apiName).toList(),
    'addedAt': addedAt.toIso8601String(),
  };

  /// Deserializes an entity from a JSON map.
  factory FavoritePokemon.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'] as List<dynamic>? ?? const [];
    return FavoritePokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String? ?? '',
      types: rawTypes
          .map((t) => PokemonType.fromApiName(t.toString()))
          .whereType<PokemonType>()
          .toList(),
      addedAt:
          DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Converts this bookmark into a [PokemonIndexEntry] for card presentation.
  PokemonIndexEntry toIndexEntry() {
    return PokemonIndexEntry(
      id: id,
      name: name,
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/$id/',
      types: types,
      customSpriteUrl: spriteUrl.isNotEmpty ? spriteUrl : null,
    );
  }

  @override
  List<Object?> get props => [id, name, spriteUrl, types, addedAt];
}
