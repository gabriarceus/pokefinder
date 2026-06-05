import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/form_name_formatter.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.selectedFormName,
    required this.pokemonId,
    required this.typeImage1,
    required this.typeImage2,
    required this.textColor,
  });

  final String selectedFormName;
  final int pokemonId;
  final String typeImage1;
  final String typeImage2;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final displayFormName = formatFormName(context, selectedFormName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayFormName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Text(
                '#${pokemonId.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TypeImage(type: typeImage1),
              if (typeImage2.isNotEmpty) ...[
                const SizedBox(width: 8),
                TypeImage(type: typeImage2),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
