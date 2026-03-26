import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

import '_app_bar.dart';
import '_bloc.dart';
import '_detail_components.dart';
import '_loading.dart';
import 'failure.dart';

//Domanda:
// Per evitare che la UI crashi quando un immagine non viene caricata correttamente o i dati richiesti sono in un formato errato
// si potrebbe usare un try catch per gestire l'eccezione e mostrare un messaggio di errore all'utente?
// Anche se... c'è già un blocco try catch nel bloc che gestisce l'eccezione e mostra un messaggio di errore all'utente
// Quindi perché ogni tanto la UI crasha quando non carica correttamente i dati?

class Detail extends StatelessWidget {
  final String pokemonName;
  final _player = AudioPlayer();
  final hGap = 16.0;

// Viene passato il nome del Pokémon da visualizzare come parametro al costruttore del widget Detail
// Il widget Detail è uno stato che dipende dallo stato del bloc PokemonBlocBloc
  Detail({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PokemonBlocBuilder(
        onInitial: (_, __) => const Center(child: Text('No Data')),
        onLoading: (_, __) => const DetailLoading(),
        onFailure: (_, failure) => DetailFailure(state: failure),
        onSuccess: (context, success) {
          final pokemon = success.pokemon;

          final backgroundHelper = DetailBackgroundColor(
            type1: pokemon.type1,
            type2: pokemon.type2,
          );

          setupAudioPlayer(_player, pokemon.cry);
          Color typeColor = backgroundHelper.colorFromType();
          Color textColor = itemColorExtractor(typeColor);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: const DetailAppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              decoration: backgroundHelper.getBackgroundDecoration(),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    DetailComponents(pokemon: pokemon, textColor: textColor),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hGap),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("Pokémon cry:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              )),
                          PlaybackButton(player: _player),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
