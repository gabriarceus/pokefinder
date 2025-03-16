import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/business_logic/hydrated_bloc/language_storage.dart';
import 'package:pokefinder/language.dart';

class LanguageSelectionButton extends StatelessWidget {
  const LanguageSelectionButton({super.key, required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<LanguageCubit>().setLanguage(language.id);
        Navigator.pop(context);
      },
      /* style: ElevatedButton.styleFrom(
        backgroundColor:
            LanguageState ? Colors.red : Colors.grey,
      ), */
      child: Text((language.description),
          style: const TextStyle(color: Colors.black)),
    );
  }
}
//TODO: aggiungere la logica per cambiare il colore dei pulsanti in modo dinamico in base alla lingua selezionata