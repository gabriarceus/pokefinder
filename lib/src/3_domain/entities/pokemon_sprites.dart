import 'package:equatable/equatable.dart';

/// Image URLs of a Pokémon; each one is null when PokeAPI has no such image.
class PokemonSprites extends Equatable {
  const PokemonSprites({
    this.frontDefault,
    this.backDefault,
    this.frontShiny,
    this.backShiny,
    this.frontFemale,
    this.backFemale,
    this.frontShinyFemale,
    this.backShinyFemale,
    this.artworkDefault,
    this.artworkShiny,
    this.homeDefault,
    this.homeFemale,
    this.homeShiny,
    this.homeShinyFemale,
  });

  final String? frontDefault;
  final String? backDefault;
  final String? frontShiny;
  final String? backShiny;
  final String? frontFemale;
  final String? backFemale;
  final String? frontShinyFemale;
  final String? backShinyFemale;
  final String? artworkDefault;
  final String? artworkShiny;
  final String? homeDefault;
  final String? homeFemale;
  final String? homeShiny;
  final String? homeShinyFemale;

  @override
  List<Object?> get props => [
    frontDefault,
    backDefault,
    frontShiny,
    backShiny,
    frontFemale,
    backFemale,
    frontShinyFemale,
    backShinyFemale,
    artworkDefault,
    artworkShiny,
    homeDefault,
    homeFemale,
    homeShiny,
    homeShinyFemale,
  ];
}
