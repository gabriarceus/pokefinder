class StatCalculator {
  static int calculateMinStat(String statName, int baseValue) {
    if (statName.toLowerCase() == 'hp') {
      if (baseValue == 1) return 1; // Shedinja
      return 2 * baseValue + 110;
    }
    return ((2 * baseValue + 5) * 0.9).floor();
  }

  static int calculateMaxStat(String statName, int baseValue) {
    if (statName.toLowerCase() == 'hp') {
      if (baseValue == 1) return 1; // Shedinja
      return 2 * baseValue + 204;
    }
    return ((2 * baseValue + 99) * 1.1).floor();
  }
}
