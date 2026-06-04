import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';

class PokeTextField extends StatelessWidget {
  const PokeTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  static const Color textFieldBorderColor = AppPalette.brandRed;
  static const Color textFieldTextColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: textFieldBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textFieldBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textFieldBorderColor),
        ),
        labelText: AppLocalizations.of(context).searchTextField,
        labelStyle: TextStyle(color: textFieldTextColor),
      ),
      onChanged: onChanged,
    );
  }
}
