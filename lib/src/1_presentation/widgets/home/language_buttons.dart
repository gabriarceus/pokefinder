import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/2_application/hydrated_bloc/language_storage.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';

class LanguageSelectionButton extends StatelessWidget {
  const LanguageSelectionButton({
    super.key,
    required this.language,
    required this.languageId,
  });

  final Language language;
  final int languageId;

  @override
  Widget build(BuildContext context) {
    final buttonBackgroundColor =
        context.watch<LanguageCubit>().state == language.id
            ? Colors.red
            : Colors.grey;

    return ElevatedButton(
      onPressed: () {
        context.read<LanguageCubit>().setLanguage(language.id);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
      ),
      child: Text((language.description),
          style: const TextStyle(color: Colors.black)),
    );
  }
}
