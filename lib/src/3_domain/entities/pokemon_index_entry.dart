import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Represents a lightweight entry in the Pokémon index catalog.
class PokemonIndexEntry extends Equatable {
  const PokemonIndexEntry({
    required this.id,
    required this.name,
    required this.detailUrl,
    this.types = const [],
    this.customSpriteUrl,
  });

  /// Canonical numeric Pokédex identifier.
  final int id;

  /// Canonical lowercase name slug (e.g. "pikachu").
  final String name;

  /// Canonical resource URL for full Pokémon details.
  final String detailUrl;

  /// Known elemental types for this Pokémon, or empty when not yet enriched.
  final List<PokemonType> types;

  /// Custom sprite URL override, if any.
  final String? customSpriteUrl;

  /// Standard pixel front-default sprite URL derived from [id].
  String get spriteUrl =>
      customSpriteUrl ??
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  /// High-resolution official artwork URL derived from [id].
  String get officialArtworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  /// Formats the [id] with a leading '#' and minimum 3 digits (e.g. "#025").
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Resolves the Pokémon generation (1-9) based on canonical Pokédex ID ranges,
  /// or 0 for alternate forms outside standard generation bounds.
  int get generation {
    if (id >= 1 && id <= 151) return 1;
    if (id >= 152 && id <= 251) return 2;
    if (id >= 252 && id <= 386) return 3;
    if (id >= 387 && id <= 493) return 4;
    if (id >= 494 && id <= 649) return 5;
    if (id >= 650 && id <= 721) return 6;
    if (id >= 722 && id <= 809) return 7;
    if (id >= 810 && id <= 905) return 8;
    if (id >= 906 && id <= 1025) return 9;
    return 0;
  }

  PokemonIndexEntry copyWith({
    int? id,
    String? name,
    String? detailUrl,
    List<PokemonType>? types,
    String? customSpriteUrl,
  }) {
    return PokemonIndexEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      detailUrl: detailUrl ?? this.detailUrl,
      types: types ?? this.types,
      customSpriteUrl: customSpriteUrl ?? this.customSpriteUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, detailUrl, types, customSpriteUrl];
}
