import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Lightweight history record for a viewed Pokémon.
class RecentPokemon extends Equatable {
  const RecentPokemon({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
    required this.viewedAt,
  });

  /// Pokédex identifier.
  final int id;

  /// Canonical name of the Pokémon.
  final String name;

  /// URL of the default sprite image.
  final String spriteUrl;

  /// Pokémon elemental types.
  final List<PokemonType> types;

  /// Timestamp when the entry was last viewed.
  final DateTime viewedAt;

  /// Serializes this entity to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spriteUrl': spriteUrl,
    'types': types.map((t) => t.apiName).toList(),
    'viewedAt': viewedAt.toIso8601String(),
  };

  /// Deserializes an entity from a JSON map.
  factory RecentPokemon.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'] as List<dynamic>? ?? const [];
    return RecentPokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String? ?? '',
      types: rawTypes
          .map((t) => PokemonType.fromApiName(t.toString()))
          .whereType<PokemonType>()
          .toList(),
      viewedAt:
          DateTime.tryParse(json['viewedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Converts this record into a [PokemonIndexEntry] for card presentation.
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
  List<Object?> get props => [id, name, spriteUrl, types, viewedAt];
}
