import 'package:flutter/material.dart';

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
                value.substring(0, 1).toUpperCase() + value.substring(1),
                style: TextStyle(
                  color: textColor,
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
