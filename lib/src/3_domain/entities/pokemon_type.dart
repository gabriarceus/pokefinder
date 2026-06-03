/// A Pokémon elemental type, modelled once with its PokeAPI numeric [id] and
/// canonical [apiName]. The [id] matches the type-sprite file name and the
/// `/type/{id}/` resource; [apiName] is the lowercase slug (e.g. "fire").
enum PokemonType {
  normal(1, 'normal'),
  fighting(2, 'fighting'),
  flying(3, 'flying'),
  poison(4, 'poison'),
  ground(5, 'ground'),
  rock(6, 'rock'),
  bug(7, 'bug'),
  ghost(8, 'ghost'),
  steel(9, 'steel'),
  fire(10, 'fire'),
  water(11, 'water'),
  grass(12, 'grass'),
  electric(13, 'electric'),
  psychic(14, 'psychic'),
  ice(15, 'ice'),
  dragon(16, 'dragon'),
  dark(17, 'dark'),
  fairy(18, 'fairy'),
  stellar(19, 'stellar');

  const PokemonType(this.id, this.apiName);

  final int id;
  final String apiName;

  /// Resolves the type matching the given numeric [id], or null when no known
  /// type uses it.
  static PokemonType? fromId(int id) {
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
