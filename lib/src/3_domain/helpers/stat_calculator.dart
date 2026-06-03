/// The kinds of base stats a Pokémon has.
///
/// HP follows a different min/max formula than the other five stats, so the
/// kind is modelled explicitly instead of branching on a free-form string.
enum StatKind { hp, attack, defense, specialAttack, specialDefense, speed }

/// Computes the in-game minimum and maximum value of a base stat.
///
/// The formulas differ only between [StatKind.hp] and the remaining stats;
/// the exhaustive switch makes adding a new [StatKind] a compile-time error.
class StatCalculator {
  static int calculateMinStat(StatKind kind, int baseValue) {
    switch (kind) {
      case StatKind.hp:
        if (baseValue == 1) return 1; // Shedinja
        return 2 * baseValue + 110;
      case StatKind.attack:
      case StatKind.defense:
      case StatKind.specialAttack:
      case StatKind.specialDefense:
      case StatKind.speed:
        return ((2 * baseValue + 5) * 0.9).floor();
    }
  }

  static int calculateMaxStat(StatKind kind, int baseValue) {
    switch (kind) {
      case StatKind.hp:
        if (baseValue == 1) return 1; // Shedinja
        return 2 * baseValue + 204;
      case StatKind.attack:
      case StatKind.defense:
      case StatKind.specialAttack:
      case StatKind.specialDefense:
      case StatKind.speed:
        return ((2 * baseValue + 99) * 1.1).floor();
    }
  }
}
