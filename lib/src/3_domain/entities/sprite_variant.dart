import 'package:equatable/equatable.dart';

/// The distinct artwork/sprite renderings exposed by PokeAPI for a Pokémon.
///
/// Covers the top-level pixel sprites (`front/back`, `shiny`, female
/// variants), `other/official-artwork`, and `other/home`. `versions`,
/// `dream_world`, and `showdown` payloads are intentionally excluded: they
/// are generation-specific or animated and outside the offline gallery scope.
enum SpriteVariantKind {
  artworkDefault,
  artworkShiny,
  frontDefault,
  backDefault,
  frontShiny,
  backShiny,
  frontFemale,
  backFemale,
  frontShinyFemale,
  backShinyFemale,
  homeDefault,
  homeFemale,
  homeShiny,
  homeShinyFemale,
}

/// A single gallery entry: the [kind] of rendering and its image [url].
///
/// The [url] is nullable because every PokeAPI sprite field is genuinely
/// nullable (e.g. genderless Pokémon omit female variants, some forms omit
/// home artwork). Callers must handle null by showing a placeholder, never
/// by crashing or rendering a blank hole.
class SpriteVariant extends Equatable {
  const SpriteVariant({required this.kind, required this.url});

  final SpriteVariantKind kind;
  final String? url;

  /// Whether this variant is a shiny rendering.
  bool get isShiny => switch (kind) {
    SpriteVariantKind.artworkShiny ||
    SpriteVariantKind.frontShiny ||
    SpriteVariantKind.backShiny ||
    SpriteVariantKind.frontShinyFemale ||
    SpriteVariantKind.backShinyFemale ||
    SpriteVariantKind.homeShiny ||
    SpriteVariantKind.homeShinyFemale => true,
    _ => false,
  };

  @override
  List<Object?> get props => [kind, url];
}
