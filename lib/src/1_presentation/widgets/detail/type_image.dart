import 'package:flutter/material.dart';

class TypeImage extends StatelessWidget {
  const TypeImage({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    if (type.isEmpty) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 144 * 0.75,
          height: 32 * 0.75,
          child: Image.network(
            type,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ),
    );
  }
}
