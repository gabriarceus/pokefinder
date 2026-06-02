import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/4_repository/services/audio_player.dart';

import '_app_bar.dart';
import '_bloc.dart';
import '_loading.dart';
import 'failure.dart';
import 'tabs/tabs.dart';
import 'widgets/detail_header.dart';
import 'widgets/form_selection_bottom_sheet.dart';

export '_bloc.dart';

class Detail extends StatefulWidget {
  // The name of the Pokémon to display is passed as a parameter to the Detail widget constructor
  // The Detail widget is a state that depends on the state of the PokemonBloc
  const Detail({super.key, required this.pokemonName});

  final String pokemonName;
  final hGap = 16.0;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final _player = AudioPlayer();
  String? _loadedCry;
  bool _showShiny = false;
  bool _hasTappedForm = false;

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

  void _showFormSelectionBottomSheet(
      BuildContext context, Pokemon pokemon, Color typeColor, Color textColor) {
    if (!_hasTappedForm) {
      setState(() => _hasTappedForm = true);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return FormSelectionBottomSheet(
          pokemon: pokemon,
          typeColor: typeColor,
          textColor: textColor,
          showShiny: _showShiny,
          onShinyChanged: (val) {
            setState(() {
              _showShiny = val;
            });
          },
        );
      },
    );
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
          final formDetails = success.selectedFormDetails ??
              PokemonFormDetails(
                name: pokemon.name,
                type1: pokemon.type1,
                type2: pokemon.type2,
                typeImage1: pokemon.typeImage1,
                typeImage2: pokemon.typeImage2,
                spriteDefault: pokemon.sprite,
                spriteShiny: pokemon.spriteFrontShiny ?? pokemon.sprite,
                artworkDefault:
                    pokemon.officialArtworkDefault ?? pokemon.sprite,
                artworkShiny: pokemon.officialArtworkShiny ??
                    pokemon.spriteFrontShiny ??
                    pokemon.sprite,
              );

          final backgroundHelper = TypeColorScheme(
            type1: formDetails.type1,
            type2: formDetails.type2,
          );

          // Load the audio only if the cry has changed
          _setupAudioIfNeeded(pokemon.cry);
          final typeColor = backgroundHelper.colorFromType();
          final textColor = contrastingTextColor(typeColor);

          final normalImage = formDetails.spriteDefault;
          final shinyImage = formDetails.spriteShiny;

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: const DetailAppBar(
                backgroundColor: Colors.transparent,
              ),
              body: Container(
                decoration: backgroundHelper.getBackgroundDecoration(),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            8),
                    DetailHeader(
                      selectedFormName: formDetails.name,
                      pokemonId: pokemon.id,
                      typeImage1: formDetails.typeImage1,
                      typeImage2: formDetails.typeImage2,
                      textColor: textColor,
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
                              child: Column(
                                children: [
                                  const SizedBox(height: 60),
                                  TabBar(
                                    isScrollable: false,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: typeColor.withValues(alpha: 0.15),
                                    ),
                                    labelColor: typeColor,
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    unselectedLabelColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.5),
                                    unselectedLabelStyle: const TextStyle(
                                      fontSize: 11,
                                    ),
                                    tabs: [
                                      Tab(
                                        text: context.t().tabInfo,
                                        icon: const Icon(Icons.info_outline),
                                      ),
                                      Tab(
                                        text: context.t().tabStats,
                                        icon: const Icon(Icons.bar_chart),
                                      ),
                                      Tab(
                                        text: context.t().tabMoves,
                                        icon: const Icon(Icons.bolt),
                                      ),
                                      Tab(
                                        text: context.t().tabItemsGames,
                                        icon:
                                            const Icon(Icons.backpack_outlined),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 16.0,
                                        left: 24.0,
                                        right: 24.0,
                                      ),
                                      child: TabBarView(
                                        children: [
                                          DetailInfoTab(
                                            pokemon: pokemon,
                                            textColor: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                            player: _player,
                                          ),
                                          DetailStatsTab(
                                            pokemon: pokemon,
                                            textColor: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                          DetailMovesTab(
                                            pokemon: pokemon,
                                            textColor: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                          DetailItemsGamesTab(
                                            pokemon: pokemon,
                                            textColor: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color ??
                                                Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -95,
                            right: 24,
                            child: GestureDetector(
                              onTap: () => _showFormSelectionBottomSheet(
                                  context, pokemon, typeColor, textColor),
                              child: Tooltip(
                                message: context.t().formSelectorTitle,
                                child: SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 300),
                                    crossFadeState: _showShiny
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    firstChild:
                                        SpriteBoxImage(sprite: normalImage),
                                    secondChild:
                                        SpriteBoxImage(sprite: shinyImage),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
