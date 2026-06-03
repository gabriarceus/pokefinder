import 'package:flutter/material.dart';

/// A flat [Card] with a translucent surface-container color and rounded corners.
///
/// Centralizes the shared surface styling used across detail panels: no
/// elevation, [Theme]'s `surfaceContainerHighest` tinted by [alpha], and a
/// [RoundedRectangleBorder] with the given [borderRadius]. When [margin] is
/// null the underlying [Card] keeps its default margin.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.alpha = 0.2,
    this.borderRadius = 16,
    this.margin,
  });

  final Widget child;
  final double alpha;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: margin,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: alpha),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
