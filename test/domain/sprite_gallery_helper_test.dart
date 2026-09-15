import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/entities/sprite_variant.dart';
import 'package:pokefinder/src/3_domain/helpers/sprite_gallery_helper.dart';

import '../fixtures/pokemon_fixture.dart';

void main() {
  group('SpriteGalleryHelper.resolvePrimarySprite', () {
    test('prefers official artwork over front default', () {
      expect(
        SpriteGalleryHelper.resolvePrimarySprite(
          artworkDefault: 'art.png',
          frontDefault: 'front.png',
          frontShiny: 'shiny.png',
          backDefault: 'back.png',
        ),
        'art.png',
      );
    });

    test('falls back to front default when artwork is missing', () {
      expect(
        SpriteGalleryHelper.resolvePrimarySprite(
          artworkDefault: null,
          frontDefault: 'front.png',
          frontShiny: 'shiny.png',
          backDefault: 'back.png',
        ),
        'front.png',
      );
    });

    test('falls back to front shiny then back default', () {
      expect(
        SpriteGalleryHelper.resolvePrimarySprite(
          artworkDefault: null,
          frontDefault: null,
          frontShiny: 'shiny.png',
          backDefault: 'back.png',
        ),
        'shiny.png',
      );
      expect(
        SpriteGalleryHelper.resolvePrimarySprite(
          artworkDefault: null,
          frontDefault: null,
          frontShiny: null,
          backDefault: 'back.png',
        ),
        'back.png',
      );
    });

    test('returns empty string when every source is missing', () {
      expect(
        SpriteGalleryHelper.resolvePrimarySprite(
          artworkDefault: null,
          frontDefault: null,
          frontShiny: null,
          backDefault: null,
        ),
        isEmpty,
      );
    });
  });

  group('SpriteGalleryHelper.buildAllVariants', () {
    test('full payload exposes all 14 variants in fallback order', () {
      final pokemon = buildPokemon(
        sprite: 'primary.png',
        spriteFrontDefault: 'front.png',
        spriteBackDefault: 'back.png',
        spriteFrontShiny: 'front-shiny.png',
        spriteBackShiny: 'back-shiny.png',
        spriteFrontFemale: 'front-female.png',
        spriteBackFemale: 'back-female.png',
        spriteFrontShinyFemale: 'front-shiny-female.png',
        spriteBackShinyFemale: 'back-shiny-female.png',
        officialArtworkDefault: 'art.png',
        officialArtworkShiny: 'art-shiny.png',
        homeDefault: 'home.png',
        homeFemale: 'home-female.png',
        homeShiny: 'home-shiny.png',
        homeShinyFemale: 'home-shiny-female.png',
      );

      final variants = SpriteGalleryHelper.buildAllVariants(pokemon);

      expect(variants, hasLength(14));
      expect(variants.map((v) => v.kind).toList(), [
        SpriteVariantKind.artworkDefault,
        SpriteVariantKind.artworkShiny,
        SpriteVariantKind.frontDefault,
        SpriteVariantKind.backDefault,
        SpriteVariantKind.frontShiny,
        SpriteVariantKind.backShiny,
        SpriteVariantKind.frontFemale,
        SpriteVariantKind.backFemale,
        SpriteVariantKind.frontShinyFemale,
        SpriteVariantKind.backShinyFemale,
        SpriteVariantKind.homeDefault,
        SpriteVariantKind.homeFemale,
        SpriteVariantKind.homeShiny,
        SpriteVariantKind.homeShinyFemale,
      ]);
      expect(variants.first.url, 'art.png');
      expect(variants[2].url, 'front.png');
      expect(variants.first.url, isNot(variants[2].url));
    });

    test('frontDefault falls back to primary sprite when missing', () {
      final pokemon = buildPokemon(sprite: 'primary.png');

      final variants = SpriteGalleryHelper.buildAllVariants(pokemon);
      final byKind = {for (final v in variants) v.kind: v.url};

      expect(byKind[SpriteVariantKind.frontDefault], 'primary.png');
    });

    test('partial payload keeps null urls for missing optionals', () {
      final pokemon = buildPokemon(
        sprite: 'front.png',
        officialArtworkDefault: 'art.png',
      );

      final variants = SpriteGalleryHelper.buildAllVariants(pokemon);
      final byKind = {for (final v in variants) v.kind: v.url};

      expect(byKind[SpriteVariantKind.artworkDefault], 'art.png');
      expect(byKind[SpriteVariantKind.frontDefault], 'front.png');
      expect(byKind[SpriteVariantKind.frontFemale], isNull);
      expect(byKind[SpriteVariantKind.homeDefault], isNull);
    });

    test('empty payload yields all-null urls without throwing', () {
      final pokemon = buildPokemon(sprite: '');

      final variants = SpriteGalleryHelper.buildAllVariants(pokemon);

      expect(variants, hasLength(14));
      // frontDefault mirrors Pokemon.sprite which may be empty; optionals null.
      expect(
        variants
            .where((v) => v.kind != SpriteVariantKind.frontDefault)
            .every((v) => v.url == null || v.url!.isEmpty),
        isTrue,
      );
      expect(SpriteGalleryHelper.buildAvailableVariants(pokemon), isEmpty);
    });
  });

  group('SpriteGalleryHelper.buildAvailableVariants', () {
    test('returns only non-empty urls in display order', () {
      final pokemon = buildPokemon(
        sprite: 'front.png',
        spriteFrontShiny: 'shiny.png',
        officialArtworkDefault: 'art.png',
        homeDefault: 'home.png',
      );

      final available = SpriteGalleryHelper.buildAvailableVariants(pokemon);

      expect(available.map((v) => v.kind), [
        SpriteVariantKind.artworkDefault,
        SpriteVariantKind.frontDefault,
        SpriteVariantKind.frontShiny,
        SpriteVariantKind.homeDefault,
      ]);
    });
  });

  group('SpriteVariant flags', () {
    test('shiny variants report isShiny', () {
      for (final kind in [
        SpriteVariantKind.artworkShiny,
        SpriteVariantKind.frontShiny,
        SpriteVariantKind.backShiny,
        SpriteVariantKind.frontShinyFemale,
        SpriteVariantKind.backShinyFemale,
        SpriteVariantKind.homeShiny,
        SpriteVariantKind.homeShinyFemale,
      ]) {
        expect(
          SpriteVariant(kind: kind, url: 'u').isShiny,
          isTrue,
          reason: '$kind',
        );
      }
      expect(
        const SpriteVariant(
          kind: SpriteVariantKind.frontDefault,
          url: 'u',
        ).isShiny,
        isFalse,
      );
    });
  });
}
