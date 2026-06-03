/// Move learn methods recognized by the UI.
///
/// [apiValue] is the PokeAPI wire code for the method. The PokeAPI exposes more
/// methods than are handled explicitly here, so [fromApi] returns `null` for
/// unrecognized codes and callers render those using their raw value.
enum LearnMethod {
  levelUp('level-up'),
  machine('machine'),
  tutor('tutor'),
  egg('egg');

  const LearnMethod(this.apiValue);

  /// The PokeAPI wire code for this learn method.
  final String apiValue;

  /// Returns the [LearnMethod] matching [value], or `null` when unrecognized.
  static LearnMethod? fromApi(String value) {
    for (final method in LearnMethod.values) {
      if (method.apiValue == value) return method;
    }
    return null;
  }
}
