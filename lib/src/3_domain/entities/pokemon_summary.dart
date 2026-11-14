import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/pokeapi_url_helper.dart';

/// Identity, image, types and form lineage of a Pokémon or form, as shown in
/// lists.
///
/// [id] always identifies the exact form [name] refers to, never the parent
/// species: the two are distinct list entries everywhere this is stored.
class PokemonSummary extends Equatable {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
    this.parentSpeciesId,
    this.parentSpeciesName,
    this.formCategory = PokemonFormCategory.canonical,
    this.regionalGroup,
  });

  /// Deserializes a summary from a JSON map.
  ///
  /// Throws a [FormatException] for invalid identity or parent species name. Form
  /// lineage is optional: records written before it was stored load as
  /// canonical.
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
    final rawParentId = json['parentSpeciesId'];
    final rawParentName = json['parentSpeciesName'];
    if (rawParentName != null && rawParentName is! String) {
      throw const FormatException('Invalid parent species name.');
    }
    return PokemonSummary(
      id: id,
      name: name,
      spriteUrl: rawSpriteUrl is String ? rawSpriteUrl : '',
      types: (rawTypes is List ? rawTypes : const [])
          .map((t) => PokemonType.fromApiName(t.toString()))
          .whereType<PokemonType>()
          .toList(),
      parentSpeciesId: rawParentId is int ? rawParentId : null,
      parentSpeciesName: rawParentName as String?,
      formCategory: _formCategoryFromName(json['formCategory']),
      regionalGroup: _regionalGroupFromName(json['regionalGroup']),
    );
  }

  static PokemonFormCategory _formCategoryFromName(Object? raw) {
    if (raw is! String) return PokemonFormCategory.canonical;
    return PokemonFormCategory.values.firstWhere(
      (category) => category.name == raw,
      orElse: () => PokemonFormCategory.canonical,
    );
  }

  static PokemonRegionalGroup? _regionalGroupFromName(Object? raw) {
    if (raw is! String) return null;
    for (final group in PokemonRegionalGroup.values) {
      if (group.name == raw) return group;
    }
    return null;
  }

  /// Pokédex identifier of this exact form, not of its parent species.
  final int id;

  /// Canonical lowercase name slug (e.g. `pikachu`, `charizard-mega-x`).
  final String name;

  /// URL of the default sprite image; empty when unknown.
  final String spriteUrl;
  final List<PokemonType> types;

  /// Pokédex identifier of the parent species, or [id] when canonical.
  final int? parentSpeciesId;

  /// Name slug of the parent species, or null when canonical.
  final String? parentSpeciesName;

  /// Structural form classification category.
  final PokemonFormCategory formCategory;

  /// Regional group, when this is a regional form.
  final PokemonRegionalGroup? regionalGroup;

  /// Serializes this summary to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spriteUrl': spriteUrl,
    'types': types.map((t) => t.apiName).toList(),
    'parentSpeciesId': parentSpeciesId,
    'parentSpeciesName': parentSpeciesName,
    'formCategory': formCategory.name,
    'regionalGroup': regionalGroup?.name,
  };

  /// Converts this summary into a [PokemonIndexEntry] for card presentation.
  PokemonIndexEntry toIndexEntry() => PokemonIndexEntry(
    id: id,
    name: name,
    detailUrl: PokeApiUrlHelper.pokemonUrl('$id'),
    types: types,
    customSpriteUrl: spriteUrl.isNotEmpty ? spriteUrl : null,
    parentSpeciesId: parentSpeciesId,
    parentSpeciesName: parentSpeciesName,
    formCategory: formCategory,
    regionalGroup: regionalGroup,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    spriteUrl,
    types,
    parentSpeciesId,
    parentSpeciesName,
    formCategory,
    regionalGroup,
  ];
}
