import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/helpers/index_suggestions_filter.dart';

class PokeTextField extends StatelessWidget {
  const PokeTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.optionsBuilder,
    this.allEntries = const [],
    this.onSubmitted,
    this.nameIndexFailure,
    this.onRetryIndex,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final AutocompleteOptionsBuilder<String>? optionsBuilder;
  final List<PokemonIndexEntry> allEntries;
  final void Function(String)? onSubmitted;
  final PokemonFailure? nameIndexFailure;
  final VoidCallback? onRetryIndex;
  final String? errorText;

  static const Color textFieldBorderColor = AppPalette.brandRed;
  static const Color textFieldTextColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    var handledBySelection = false;

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder:
          optionsBuilder ??
          (TextEditingValue textEditingValue) {
            return filterIndexSuggestions(allEntries, textEditingValue.text);
          },
      onSelected: (String selection) {
        handledBySelection = true;
        onChanged(selection);
        onSubmitted?.call(selection);
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                handledBySelection = false;
                onFieldSubmitted();
                if (!handledBySelection) {
                  onSubmitted?.call(value);
                }
              },
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
                errorText: errorText,
                labelText: AppLocalizations.of(context).searchTextField,
                labelStyle: const TextStyle(color: textFieldTextColor),
                suffixIcon: nameIndexFailure != null
                    ? Tooltip(
                        message: t.errorSuggestions,
                        child: IconButton(
                          icon: const Icon(
                            Icons.sync_problem_rounded,
                            color: Colors.orange,
                          ),
                          onPressed: onRetryIndex,
                        ),
                      )
                    : null,
              ),
              onChanged: onChanged,
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final availableWidth = (screenWidth - 48).clamp(200.0, 400.0);

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: availableWidth,
                maxHeight: 250,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  PokemonIndexEntry? matchedEntry;
                  for (final entry in allEntries) {
                    if (entry.name == option) {
                      matchedEntry = entry;
                      break;
                    }
                  }

                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(option)),
                            if (matchedEntry != null &&
                                matchedEntry.isAlternateForm &&
                                matchedEntry.formBadgeText != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.purple.shade300,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  matchedEntry.formBadgeText!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
