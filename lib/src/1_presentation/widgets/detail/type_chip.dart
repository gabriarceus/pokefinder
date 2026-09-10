import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/contrasting_text_color.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/type_color_scheme.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// An accessible chip displaying a Pokémon elemental type badge or localized text.
///
/// Falls back to a high-contrast localized text chip when badge images fail to
/// load or when an image URL is unavailable.
class TypeChip extends StatefulWidget {
  const TypeChip({super.key, required this.type, this.imageUrl});

  final PokemonType type;
  final String? imageUrl;

  @override
  State<TypeChip> createState() => _TypeChipState();
}

class _TypeChipState extends State<TypeChip> {
  bool _hasError = false;

  @override
  void didUpdateWidget(covariant TypeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.type != widget.type) {
      _hasError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeName = context.translateType(widget.type.apiName);
    final typeColor = TypeColorScheme.getColorFromType(widget.type);
    final textColor = contrastingTextColor(typeColor);

    final showImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty && !_hasError;

    final Widget content;
    if (showImage) {
      content = Image.network(
        widget.imageUrl!,
        width: 144 * 0.75,
        height: 32 * 0.75,
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasError) {
              setState(() {
                _hasError = true;
              });
            }
          });
          return _buildTextChip(typeName, typeColor, textColor);
        },
      );
    } else {
      content = _buildTextChip(typeName, typeColor, textColor);
    }

    return Semantics(
      label: typeName,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(showImage ? 4 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildTextChip(String typeName, Color typeColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        typeName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
