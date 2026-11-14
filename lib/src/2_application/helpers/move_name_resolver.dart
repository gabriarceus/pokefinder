/// Returns the display name of a move from its PokeAPI slug.
class MoveNameResolver {
  const MoveNameResolver(this._resolve);

  final String Function(String slug) _resolve;

  String call(String slug) => _resolve(slug);
}
