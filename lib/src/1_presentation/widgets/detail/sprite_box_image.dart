import 'package:flutter/material.dart';

/// A square network image of a Pokémon sprite, with a progress indicator
/// while it loads and an icon when it fails.
class SpriteBoxImage extends StatelessWidget {
  const SpriteBoxImage({super.key, required this.sprite, this.size = 144});

  final String sprite;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.5);
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        sprite,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, _, _) {
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: placeholderColor,
            ),
          );
        },
      ),
    );
  }
}
