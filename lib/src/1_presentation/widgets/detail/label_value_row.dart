import 'package:flutter/material.dart';

/// A row with a muted [label] on the left and a bold [value] on the right.
///
/// With [onTap], the value is drawn as a link.
class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.textColor,
    this.onTap,
  });

  final String label;
  final String value;

  /// Defaults to the theme's `onSurface`.
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: onTap != null ? theme.colorScheme.primary : color,
      decoration: onTap != null ? TextDecoration.underline : null,
    );
    final valueText = Text(
      value,
      textAlign: TextAlign.right,
      style: valueStyle,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: onTap != null
                ? InkWell(onTap: onTap, child: valueText)
                : valueText,
          ),
        ],
      ),
    );
  }
}
