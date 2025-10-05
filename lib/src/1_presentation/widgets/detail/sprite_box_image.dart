import 'package:flutter/material.dart';

class SpriteBoxImage extends StatelessWidget {
  const SpriteBoxImage({
    super.key,
    required this.sprite,
  });

  final String sprite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96 * 1.5,
      height: 96 * 1.5,
      child: Image.network(
        sprite,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Text(":(");
        },
      ),
    );
  }
}
