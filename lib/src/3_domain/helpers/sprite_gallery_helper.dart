import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/sprite_variant.dart';

/// Builds the artwork/sprite-variant gallery model from a [Pokemon].
///
/// The display order preserves the repository fallback order
/// (official artwork → front default → others), then female variants,
/// then Home renderings. Only URLs are recorded; image bytes are left to
/// the platform image cache (no new binary cache).
class SpriteGalleryHelper {
  const SpriteGalleryHelper._();

  /// Returns every variant in display order, including entries with a null
  /// [SpriteVariant.url] for genuinely missing PokeAPI fields.
  static List<SpriteVariant> buildAllVariants(Pokemon pokemon) => [
    SpriteVariant(
      kind: SpriteVariantKind.artworkDefault,
      url: pokemon.officialArtworkDefault,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.artworkShiny,
      url: pokemon.officialArtworkShiny,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.frontDefault,
      url: pokemon.spriteFrontDefault ?? pokemon.sprite,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.backDefault,
      url: pokemon.spriteBackDefault,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.frontShiny,
      url: pokemon.spriteFrontShiny,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.backShiny,
      url: pokemon.spriteBackShiny,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.frontFemale,
      url: pokemon.spriteFrontFemale,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.backFemale,
      url: pokemon.spriteBackFemale,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.frontShinyFemale,
      url: pokemon.spriteFrontShinyFemale,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.backShinyFemale,
      url: pokemon.spriteBackShinyFemale,
    ),
    SpriteVariant(
      kind: SpriteVariantKind.homeDefault,
      url: pokemon.homeDefault,
    ),
    SpriteVariant(kind: SpriteVariantKind.homeFemale, url: pokemon.homeFemale),
    SpriteVariant(kind: SpriteVariantKind.homeShiny, url: pokemon.homeShiny),
    SpriteVariant(
      kind: SpriteVariantKind.homeShinyFemale,
      url: pokemon.homeShinyFemale,
    ),
  ];

  /// Returns only the variants with a non-empty URL, in display order.
  static List<SpriteVariant> buildAvailableVariants(Pokemon pokemon) =>
      buildAllVariants(
        pokemon,
      ).where((v) => v.url != null && v.url!.isNotEmpty).toList();

  /// Resolves the primary sprite with the canonical fallback order:
  /// official artwork → front default → front shiny → back default.
  /// Returns an empty string when every source is missing.
  static String resolvePrimarySprite({
    required String? artworkDefault,
    required String? frontDefault,
    required String? frontShiny,
    required String? backDefault,
  }) => artworkDefault ?? frontDefault ?? frontShiny ?? backDefault ?? '';
}
