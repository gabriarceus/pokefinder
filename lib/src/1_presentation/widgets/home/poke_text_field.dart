import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';

class PokeTextField extends StatelessWidget {
  const PokeTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.allNames,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final List<String> allNames;
  static const Color textFieldBorderColor = AppPalette.brandRed;
  static const Color textFieldTextColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.length < 2) {
          return const Iterable<String>.empty();
        }
        final query = textEditingValue.text.toLowerCase();
        return allNames
            .where((name) => name.toLowerCase().startsWith(query))
            .take(5);
      },
      onSelected: (String selection) {
        onChanged(selection);
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: textFieldBorderColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: textFieldBorderColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: textFieldBorderColor),
            ),
            labelText: AppLocalizations.of(context).searchTextField,
            labelStyle: const TextStyle(color: textFieldTextColor),
          ),
          onChanged: onChanged,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              width: 200,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
