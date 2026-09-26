import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/pokeapi_url_helper.dart';

/// Identity, image and types of a Pokémon or form, as shown in lists.
class PokemonSummary extends Equatable {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
  });

  /// Deserializes a summary from a JSON map.
  ///
  /// Throws a [FormatException] when the id or the name is missing.
  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final rawName = json['name'];
    final name = rawName is String ? rawName.trim() : '';
    if (id == null || id <= 0 || name.isEmpty) {
      throw FormatException('Corrupt Pokémon summary: $json');
    }
    final rawSpriteUrl = json['spriteUrl'];
    final rawTypes = json['types'];
    return PokemonSummary(
      id: id,
      name: name,
      spriteUrl: rawSpriteUrl is String ? rawSpriteUrl : '',
      types: (rawTypes is List ? rawTypes : const [])
          .map((t) => PokemonType.fromApiName(t.toString()))
          .whereType<PokemonType>()
          .toList(),
    );
  }

  /// Pokédex identifier.
  final int id;

  /// Canonical lowercase name slug (e.g. `pikachu`, `charizard-mega-x`).
  final String name;

  /// URL of the default sprite image; empty when unknown.
  final String spriteUrl;
  final List<PokemonType> types;

  /// Serializes this summary to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spriteUrl': spriteUrl,
    'types': types.map((t) => t.apiName).toList(),
  };

  /// Converts this summary into a [PokemonIndexEntry] for card presentation.
  PokemonIndexEntry toIndexEntry() => PokemonIndexEntry(
    id: id,
    name: name,
    detailUrl: PokeApiUrlHelper.pokemonUrl('$id'),
    types: types,
    customSpriteUrl: spriteUrl.isNotEmpty ? spriteUrl : null,
  );

  @override
  List<Object?> get props => [id, name, spriteUrl, types];
}
