import 'package:flutter/material.dart';

class SpriteBoxImage extends StatelessWidget {
  const SpriteBoxImage({super.key, required this.sprite});

  final String sprite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96 * 1.5,
      height: 96 * 1.5,
      child: Image.network(
        sprite,
        fit: BoxFit.contain,
        errorBuilder: (context, _, _) {
          return Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
          );
        },
      ),
    );
  }
}
