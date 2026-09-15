import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/surface_card.dart';
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

/// Grid gallery of the available artwork/sprite variants for a Pokémon.
///
/// Shows only variants with a recorded URL ([SpriteGalleryHelper] supplies
/// URLs + fallback order; image bytes stay in the platform image cache, no
/// new binary cache). Missing payloads render a placeholder card instead of
/// a blank hole, and every failed image renders a placeholder icon.
class SpriteGalleryWidget extends StatelessWidget {
  const SpriteGalleryWidget({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final variants = SpriteGalleryHelper.buildAvailableVariants(pokemon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t().spriteTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        if (variants.isEmpty)
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 36,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.t().noData,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.68,
            ),
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              return _SpriteGalleryTile(variant: variant, textColor: textColor);
            },
          ),
      ],
    );
  }
}

class _SpriteGalleryTile extends StatelessWidget {
  const _SpriteGalleryTile({required this.variant, required this.textColor});

  final SpriteVariant variant;
  final Color textColor;

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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                          color: textColor.withValues(alpha: 0.4),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, _, _) => Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: textColor.withValues(alpha: 0.4),
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
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
