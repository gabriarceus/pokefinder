import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/surface_card.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Returns the localized label for a sprite [kind].
String spriteVariantLabel(BuildContext context, SpriteVariantKind kind) {
  final t = context.t();
  return switch (kind) {
    SpriteVariantKind.artworkDefault => t.galleryArtworkDefault,
    SpriteVariantKind.artworkShiny => t.galleryArtworkShiny,
    SpriteVariantKind.frontDefault => t.galleryFrontDefault,
    SpriteVariantKind.backDefault => t.galleryBackDefault,
    SpriteVariantKind.frontShiny => t.galleryFrontShiny,
    SpriteVariantKind.backShiny => t.galleryBackShiny,
    SpriteVariantKind.frontFemale => t.galleryFrontFemale,
    SpriteVariantKind.backFemale => t.galleryBackFemale,
    SpriteVariantKind.frontShinyFemale => t.galleryFrontShinyFemale,
    SpriteVariantKind.backShinyFemale => t.galleryBackShinyFemale,
    SpriteVariantKind.homeDefault => t.galleryHomeDefault,
    SpriteVariantKind.homeFemale => t.galleryHomeFemale,
    SpriteVariantKind.homeShiny => t.galleryHomeShiny,
    SpriteVariantKind.homeShinyFemale => t.galleryHomeShinyFemale,
  };
}

/// Horizontal strip of the available artwork/sprite variants for a Pokémon.
///
/// Shows only variants with a recorded URL ([SpriteGalleryHelper] supplies
/// URLs + fallback order; image bytes stay in the platform image cache, no
/// new binary cache). Tiles have the same size; a tap opens a larger preview.
class SpriteGalleryWidget extends StatelessWidget {
  const SpriteGalleryWidget({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final variants = SpriteGalleryHelper.buildAvailableVariants(pokemon);
    final mutedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(context.t().spriteTitle),
        if (variants.isEmpty)
          SurfaceCard(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 36,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.t().noData)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: _kTileHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: variants.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) =>
                  _SpriteGalleryTile(variant: variants[index]),
            ),
          ),
      ],
    );
  }
}

const _kTileWidth = 104.0;
const _kTileHeight = 136.0;

class _SpriteGalleryTile extends StatelessWidget {
  const _SpriteGalleryTile({required this.variant});

  final SpriteVariant variant;

  void _showPreview(BuildContext context, String label) {
    final url = variant.url;
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, _) => Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = spriteVariantLabel(context, variant.kind);
    final url = variant.url;
    final mutedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.4);

    return Semantics(
      button: true,
      image: true,
      excludeSemantics: true,
      label: label,
      hint: variant.isShiny ? context.t().formSelectorShiny : null,
      child: InkWell(
        onTap: url == null || url.isEmpty
            ? null
            : () => _showPreview(context, label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: _kTileWidth,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: url == null || url.isEmpty
                      ? Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: mutedColor,
                        )
                      : Image.network(
                          url,
                          width: 88,
                          height: 88,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, _, _) => Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: mutedColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
