import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/4_repository/repository.dart';

import '_app_bar.dart';
import '_bloc.dart';
import '_detail_components.dart';

export '_bloc.dart';
import '_loading.dart';
import 'failure.dart';

//Domanda:
// Per evitare che la UI crashi quando un immagine non viene caricata correttamente o i dati richiesti sono in un formato errato
// si potrebbe usare un try catch per gestire l'eccezione e mostrare un messaggio di errore all'utente?
// Anche se... c'è già un blocco try catch nel bloc che gestisce l'eccezione e mostra un messaggio di errore all'utente
// Quindi perché ogni volta la UI crasha quando non carica correttamente i dati?

class Detail extends StatefulWidget {
  final String pokemonName;
  final hGap = 16.0;

// Viene passato il nome del Pokémon da visualizzare come parametro al costruttore del widget Detail
// Il widget Detail è uno stato che dipende dallo stato del bloc PokemonBlocBloc
  const Detail({super.key, required this.pokemonName});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final _player = AudioPlayer();
  String? _loadedCry;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _setupAudioIfNeeded(String cry) {
    if (_loadedCry != cry) {
      _loadedCry = cry;
      setupAudioPlayer(_player, cry);
    }
  }

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

          // Carica l'audio solo se il cry è cambiato
          _setupAudioIfNeeded(pokemon.cry);
          Color typeColor = backgroundHelper.colorFromType();
          Color textColor = itemColorExtractor(typeColor);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: const DetailAppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              decoration: backgroundHelper.getBackgroundDecoration(),
              child: Column(
                children: [
                  SizedBox(
                      height:
                          MediaQuery.of(context).padding.top + kToolbarHeight),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                '${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              '#${pokemon.id.toString().padLeft(3, '0')}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TypeImage(type: pokemon.typeImage1),
                            if (pokemon.typeImage2.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TypeImage(type: pokemon.typeImage2),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          top: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 60.0, left: 24.0, right: 24.0),
                              child: SingleChildScrollView(
                                child: DetailComponents(
                                  pokemon: pokemon,
                                  textColor: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color ??
                                      Colors.black,
                                  player: _player,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -60,
                          right: 24,
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: SpriteBoxImage(sprite: pokemon.sprite),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
