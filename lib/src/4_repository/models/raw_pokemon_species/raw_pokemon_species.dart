import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_pokemon_species.g.dart';

@JsonSerializable(createToJson: false)
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
}

@JsonSerializable(createToJson: false)
class RawEvolutionChainResource {
  const RawEvolutionChainResource({required this.url});

  final String url;

  factory RawEvolutionChainResource.fromJson(Map<String, dynamic> json) =>
      _$RawEvolutionChainResourceFromJson(json);
}

@JsonSerializable(createToJson: false)
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
}

@JsonSerializable(createToJson: false)
class RawSpeciesGenusEntry {
  const RawSpeciesGenusEntry({required this.genus, required this.language});

  final String genus;
  final NamedAPIResource language;

  factory RawSpeciesGenusEntry.fromJson(Map<String, dynamic> json) =>
      _$RawSpeciesGenusEntryFromJson(json);
}
