import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PokeTextField extends StatelessWidget {
  const PokeTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final Color textFieldBorderColor = Colors.red;
  final Color textFieldTextColor = Colors.black;

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
      labelText: AppLocalizations.of(context)!.searchTextField,
      labelStyle: TextStyle(color: textFieldTextColor),
      ),
      onChanged: onChanged,
    );
  }
}