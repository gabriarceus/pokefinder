import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_pokemon_species.g.dart';

@JsonSerializable(explicitToJson: true)
class RawPokemonSpecies {
  const RawPokemonSpecies({
    required this.id,
    required this.name,
    this.generation,
    this.habitat,
    this.captureRate,
    this.baseHappiness,
    this.evolutionChain,
    this.flavorTextEntries = const [],
    this.genera = const [],
  });

  final int id;
  final String name;
  final NamedAPIResource? generation;
  final NamedAPIResource? habitat;

  @JsonKey(name: 'capture_rate')
  final int? captureRate;

  @JsonKey(name: 'base_happiness')
  final int? baseHappiness;

  @JsonKey(name: 'evolution_chain')
  final RawEvolutionChainResource? evolutionChain;

  @JsonKey(name: 'flavor_text_entries')
  final List<RawSpeciesFlavorTextEntry> flavorTextEntries;

  final List<RawSpeciesGenusEntry> genera;

  factory RawPokemonSpecies.fromJson(Map<String, dynamic> json) =>
      _$RawPokemonSpeciesFromJson(json);

  Map<String, dynamic> toJson() => _$RawPokemonSpeciesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawEvolutionChainResource {
  const RawEvolutionChainResource({required this.url});

  final String url;

  factory RawEvolutionChainResource.fromJson(Map<String, dynamic> json) =>
      _$RawEvolutionChainResourceFromJson(json);

  Map<String, dynamic> toJson() => _$RawEvolutionChainResourceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawSpeciesFlavorTextEntry {
  const RawSpeciesFlavorTextEntry({
    required this.flavorText,
    required this.language,
    this.version,
  });

  @JsonKey(name: 'flavor_text')
  final String flavorText;
  final NamedAPIResource language;
  final NamedAPIResource? version;

  factory RawSpeciesFlavorTextEntry.fromJson(Map<String, dynamic> json) =>
      _$RawSpeciesFlavorTextEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RawSpeciesFlavorTextEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawSpeciesGenusEntry {
  const RawSpeciesGenusEntry({required this.genus, required this.language});

  final String genus;
  final NamedAPIResource language;

  factory RawSpeciesGenusEntry.fromJson(Map<String, dynamic> json) =>
      _$RawSpeciesGenusEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RawSpeciesGenusEntryToJson(this);
}
