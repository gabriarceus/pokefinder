import 'package:flutter/material.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '_app_bar.dart';
import '_bloc.dart';
import '_loading.dart';
import 'failure.dart';
import 'tabs/tabs.dart';
import 'widgets/detail_header.dart';
import 'widgets/form_selection_bottom_sheet.dart';

export '_bloc.dart';

/// Detail screen displaying data for a single Pokémon, identified by [pokemonName].
class Detail extends StatefulWidget {
  const Detail({super.key, required this.pokemonName, this.searchQuery});

  final String pokemonName;
  final String? searchQuery;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final CryAudioController _audioController = getIt<CryAudioController>();
  bool _showShiny = false;
  bool _hasRecordedSearch = false;

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  void _showFormSelectionBottomSheet(
    BuildContext context,
    Pokemon pokemon,
    Color typeColor,
    Color textColor,
  ) {
    final bloc = context.read<PokemonBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    return BlocListener<PokemonBloc, PokemonBlocState>(
      listener: (context, state) {
        if (state is PokemonBlocSuccess) {
          try {
            final formDetails = state.selectedFormDetails;
            final spriteUrl =
                formDetails?.spriteDefault ?? state.pokemon.sprite;
            final types = <PokemonType>[
              if (formDetails?.type1 != null)
                formDetails!.type1!
              else if (state.pokemon.type1 != null)
                state.pokemon.type1!,
              if (formDetails?.type2 != null)
                formDetails!.type2!
              else if (state.pokemon.type2 != null)
                state.pokemon.type2!,
            ];
            context.read<RecentHistoryCubit>().addRecentPokemon(
              id: state.pokemon.id,
              name: state.pokemon.name,
              spriteUrl: spriteUrl,
              types: types,
            );
          } catch (_) {}

          if (!_hasRecordedSearch &&
              widget.searchQuery != null &&
              widget.searchQuery!.trim().isNotEmpty) {
            _hasRecordedSearch = true;
            try {
              context.read<RecentHistoryCubit>().addRecentSearch(
                widget.searchQuery!.trim(),
              );
            } catch (_) {}
          }

          try {
            final preferences = context.read<PreferencesCubit>().state;
            if (preferences.autoPlayCry && state.pokemon.cry.isNotEmpty) {
              _audioController.setVolume(preferences.cryVolume);
              _audioController.play(state.pokemon.cry);
            }
          } catch (_) {}
        }
      },
      child: Scaffold(
        body: PokemonBlocBuilder(
          onInitial: (_, _) => Center(child: Text(context.t().noData)),
          onLoading: (_, _) => const DetailLoading(),
          onFailure: (_, failure) =>
              DetailFailure(state: failure, pokemonName: widget.pokemonName),
          onSuccess: _buildSuccess,
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, PokemonBlocSuccess success) {
    final pokemon = success.pokemon;
    final formDetails = success.formDetails;

    bool isFavorite = false;
    try {
      isFavorite = context.select<FavoritesCubit, bool>(
        (cubit) => cubit.isFavorite(pokemon.id),
      );
    } catch (_) {}

    final backgroundHelper = TypeColorScheme(
      type1: formDetails.type1,
      type2: formDetails.type2,
    );

    final typeColor = backgroundHelper.colorFromType();
    final textColor = contrastingTextColor(typeColor);

    return BlocProvider<DetailGameVersionCubit>(
      create: (_) =>
          DetailGameVersionCubit()
            ..initialize(pokemon, encounters: success.encounters),
      child: BlocListener<PokemonBloc, PokemonBlocState>(
        listenWhen: (prev, curr) {
          if (prev is PokemonBlocSuccess && curr is PokemonBlocSuccess) {
            return prev.encounters != curr.encounters;
          }
          return false;
        },
        listener: (context, state) {
          if (state is PokemonBlocSuccess) {
            context.read<DetailGameVersionCubit>().initialize(
              state.pokemon,
              encounters: state.encounters,
            );
          }
        },
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: DetailAppBar(
              backgroundColor: Colors.transparent,
              showShiny: _showShiny,
              isStale: pokemon.isStale,
              isFavorite: isFavorite,
              onToggleFavorite: () {
                try {
                  final spriteUrl = formDetails.spriteDefault.isNotEmpty
                      ? formDetails.spriteDefault
                      : pokemon.sprite;
                  final types = <PokemonType>[
                    if (formDetails.type1 != null)
                      formDetails.type1!
                    else if (pokemon.type1 != null)
                      pokemon.type1!,
                    if (formDetails.type2 != null)
                      formDetails.type2!
                    else if (pokemon.type2 != null)
                      pokemon.type2!,
                  ];
                  context.read<FavoritesCubit>().toggleFavorite(
                    id: pokemon.id,
                    name: pokemon.name,
                    spriteUrl: spriteUrl,
                    types: types,
                  );
                } catch (_) {}
              },
              onToggleShiny: () {
                setState(() {
                  _showShiny = !_showShiny;
                });
              },
            ),
            body: Container(
              decoration: backgroundHelper.getBackgroundDecoration(),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;
                  final topPadding =
                      MediaQuery.of(context).padding.top + kToolbarHeight;

                  if (isLandscape) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Column(
                            children: [
                              SizedBox(height: topPadding),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: DetailHeader(
                                    selectedFormName: formDetails.name,
                                    pokemonId: pokemon.id,
                                    type1: formDetails.type1,
                                    type2: formDetails.type2,
                                    typeImage1: formDetails.typeImage1,
                                    typeImage2: formDetails.typeImage2,
                                    textColor: textColor,
                                    showShiny: _showShiny,
                                    isLandscape: true,
                                    spriteWidget: AnimatedCrossFade(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      crossFadeState: _showShiny
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      firstChild: SpriteBoxImage(
                                        sprite: formDetails.spriteDefault,
                                      ),
                                      secondChild: SpriteBoxImage(
                                        sprite: formDetails.spriteShiny,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: topPadding),
                            child: _DetailContentCard(
                              typeColor: typeColor,
                              pokemon: pokemon,
                              audioController: _audioController,
                              success: success,
                              showShiny: _showShiny,
                              selectedFormName: formDetails.name,
                              onFormTap: () => _showFormSelectionBottomSheet(
                                context,
                                pokemon,
                                typeColor,
                                textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(height: topPadding),
                      DetailHeader(
                        selectedFormName: formDetails.name,
                        pokemonId: pokemon.id,
                        type1: formDetails.type1,
                        type2: formDetails.type2,
                        typeImage1: formDetails.typeImage1,
                        typeImage2: formDetails.typeImage2,
                        textColor: textColor,
                        showShiny: _showShiny,
                        isLandscape: false,
                        spriteWidget: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _showShiny
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: SpriteBoxImage(
                            sprite: formDetails.spriteDefault,
                          ),
                          secondChild: SpriteBoxImage(
                            sprite: formDetails.spriteShiny,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _DetailContentCard(
                          typeColor: typeColor,
                          pokemon: pokemon,
                          audioController: _audioController,
                          success: success,
                          showShiny: _showShiny,
                          selectedFormName: formDetails.name,
                          onFormTap: () => _showFormSelectionBottomSheet(
                            context,
                            pokemon,
                            typeColor,
                            textColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
    required this.showShiny,
    required this.onFormTap,
    this.selectedFormName,
  });

  final Color typeColor;
  final Pokemon pokemon;
  final CryAudioController audioController;
  final PokemonBlocSuccess success;
  final bool showShiny;
  final VoidCallback onFormTap;
  final String? selectedFormName;

  @override
  Widget build(BuildContext context) {
    final tabTextColor = Theme.of(context).colorScheme.onSurface;

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
          const SizedBox(height: 16),
          _DetailTabBar(typeColor: typeColor),
          DetailGameVersionSelector(typeColor: typeColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0),
              child: TabBarView(
                children: [
                  DetailInfoTab(
                    pokemon: pokemon,
                    textColor: tabTextColor,
                    audioController: audioController,
                    typeColor: typeColor,
                    onFormTap: onFormTap,
                    selectedFormName: selectedFormName,
                  ),
                  DetailStatsTab(pokemon: pokemon, textColor: tabTextColor),
                  DetailMovesTab(pokemon: pokemon, textColor: tabTextColor),
                  DetailItemsGamesTab(
                    pokemon: pokemon,
                    textColor: tabTextColor,
                    encounters: success.encounters,
                    isLoadingEncounters: success.isLoadingEncounters,
                    encountersFailure: success.encountersFailure,
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

  /// Ensures the type color is visible as an indicator/label on a card
  /// background. Darkens overly-light colors so the selection is always clear.
  Color _effectiveIndicatorColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final luminance = typeColor.computeLuminance();
    if (brightness == Brightness.light && luminance > 0.45) {
      final hsl = HSLColor.fromColor(typeColor);
      return hsl
          .withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0))
          .withSaturation((hsl.saturation + 0.2).clamp(0.0, 1.0))
          .toColor();
    } else if (brightness == Brightness.dark && luminance < 0.2) {
      final hsl = HSLColor.fromColor(typeColor);
      return hsl
          .withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0))
          .toColor();
    }
    return typeColor;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _effectiveIndicatorColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(24),
        overlayColor: WidgetStatePropertyAll(
          effectiveColor.withValues(alpha: 0.08),
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: effectiveColor.withValues(alpha: 0.15),
        ),
        labelColor: effectiveColor,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: [
          Tab(text: context.t().tabInfo, icon: const Icon(Icons.info_outline)),
          Tab(text: context.t().tabStats, icon: const Icon(Icons.bar_chart)),
          Tab(text: context.t().tabMoves, icon: const Icon(Icons.bolt)),
          Tab(
            text: context.t().tabItemsGames,
            icon: const Icon(Icons.backpack_outlined),
          ),
        ],
      ),
    );
  }
}
