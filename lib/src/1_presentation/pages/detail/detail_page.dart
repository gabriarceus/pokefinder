import 'package:flutter/material.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

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

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final CryAudioController _audioController = getIt<CryAudioController>();
  bool _showShiny = false;
  bool _hasTappedForm = false;

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  void _showFormSelectionBottomSheet(
      BuildContext context, Pokemon pokemon, Color typeColor, Color textColor) {
    if (!_hasTappedForm) {
      setState(() => _hasTappedForm = true);
    }
    final bloc = context.read<PokemonBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: FormSelectionBottomSheet(
            pokemon: pokemon,
            typeColor: typeColor,
            textColor: textColor,
            showShiny: _showShiny,
            onShinyChanged: (val) {
              setState(() {
                _showShiny = val;
              });
            },
          ),
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
        onSuccess: _buildSuccess,
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, PokemonBlocSuccess success) {
    final pokemon = success.pokemon;
    final formDetails =
        success.selectedFormDetails ?? PokemonFormDetails.fromPokemon(pokemon);

    final backgroundHelper = TypeColorScheme(
      type1: formDetails.type1,
      type2: formDetails.type2,
    );

    final typeColor = backgroundHelper.colorFromType();
    final textColor = contrastingTextColor(typeColor);

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
                  height:
                      MediaQuery.of(context).padding.top + kToolbarHeight + 8),
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
                      child: _DetailContentCard(
                        typeColor: typeColor,
                        pokemon: pokemon,
                        audioController: _audioController,
                        success: success,
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
                              firstChild: SpriteBoxImage(
                                  sprite: formDetails.spriteDefault),
                              secondChild: SpriteBoxImage(
                                  sprite: formDetails.spriteShiny),
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
  }
}

/// The rounded content card holding the detail tab bar and tab views.
class _DetailContentCard extends StatelessWidget {
  const _DetailContentCard({
    required this.typeColor,
    required this.pokemon,
    required this.audioController,
    required this.success,
  });

  final Color typeColor;
  final Pokemon pokemon;
  final CryAudioController audioController;
  final PokemonBlocSuccess success;

  @override
  Widget build(BuildContext context) {
    final tabTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Container(
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
          _DetailTabBar(typeColor: typeColor),
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
                    textColor: tabTextColor,
                    audioController: audioController,
                  ),
                  DetailStatsTab(
                    pokemon: pokemon,
                    textColor: tabTextColor,
                  ),
                  DetailMovesTab(
                    pokemon: pokemon,
                    textColor: tabTextColor,
                  ),
                  DetailItemsGamesTab(
                    pokemon: pokemon,
                    textColor: tabTextColor,
                    encounters: success.encounters,
                    isLoadingEncounters: success.isLoadingEncounters,
                    encountersError: success.encountersError,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The detail screen's tab bar, themed against the active [typeColor].
class _DetailTabBar extends StatelessWidget {
  const _DetailTabBar({required this.typeColor});

  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return TabBar(
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
      unselectedLabelColor:
          Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
          icon: const Icon(Icons.backpack_outlined),
        ),
      ],
    );
  }
}
