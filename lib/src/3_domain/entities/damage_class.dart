/// The damage class of a move, representing whether it deals physical or
/// special damage, or applies a status effect.
enum DamageClass {
  physical('physical'),
  special('special'),
  status('status');

  const DamageClass(this.apiName);

  final String apiName;

  /// Resolves the damage class matching the given API [name], or null when
  /// the value is not recognized.
  static DamageClass? fromApiName(String name) {
    for (final dc in values) {
      if (dc.apiName == name) return dc;
    }
    return null;
  }
}
