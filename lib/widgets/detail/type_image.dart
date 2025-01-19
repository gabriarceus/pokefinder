import 'package:flutter/material.dart';

class TypeImage extends StatelessWidget {
  const TypeImage({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    return (type.isNotEmpty)
        ? SizedBox(
            width: 144 * 0.75,
            height: 32 * 0.75,
            child: Image.network(
              type,
              fit: BoxFit.contain,
              
            ),
          )
        : const SizedBox();
  }
}
