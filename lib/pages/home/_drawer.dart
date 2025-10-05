import 'package:flutter/material.dart';
import 'package:pokefinder/extensions.dart';
import 'package:pokefinder/widgets/home/widgets.dart';
import 'package:pokefinder/language.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

//cose da fare
// aggiungere la logica per cambiare il colore dei pulsanti in modo dinamico in base alla lingua selezionata
// creare factory per la creazione di pulsanti
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Header
          Container(
            width: double.infinity,
            color: Colors.red,
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05,
                MediaQuery.of(context).padding.top,
                0,
                20), //questo è da fare dinamico
            child: Text(
              context.t().settings,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LanguageSelectionButton(
                  language: Language.italian,
                  languageId: Language.italian.id,
                ),
                const SizedBox(width: 20),
                LanguageSelectionButton(
                  language: Language.english,
                  languageId: Language.english.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
