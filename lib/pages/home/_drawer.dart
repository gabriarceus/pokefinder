import 'package:flutter/material.dart';
import 'package:pokefinder/language_state.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

//cose da fare
// aggiungere la logica per cambiare il colore dei pulsanti in modo dinamico in base alla lingua selezionata
// creare factory per la creazione di pulsanti
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.red,
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05,
                MediaQuery.of(context).padding.top,
                0,
                20), //questo è da fare dinamico
            child: const Text(
              'Settings', //da mettere nel file di traduzione
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      LanguageState.languageNotifier.value = false;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(('ITA'),
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      LanguageState.languageNotifier.value = true;
                      Navigator.pop(context);
                    },
                    child: const Text(('ENG'),
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
