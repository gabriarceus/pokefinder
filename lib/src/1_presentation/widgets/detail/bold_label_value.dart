import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

class BoldLabelValue extends StatelessWidget {
  const BoldLabelValue({
    super.key,
    required this.label,
    required this.value,
    required this.textColor,
  });

  final String label;
  final String value;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return (value.isNotEmpty)
        ? Row(
            children: [
              Text(
                '$label: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                value.capitalize(),
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
