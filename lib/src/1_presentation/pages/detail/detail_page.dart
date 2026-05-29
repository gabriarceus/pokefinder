import 'package:flutter/material.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
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
  // Viene passato il nome del Pokémon da visualizzare come parametro al costruttore del widget Detail
  // Il widget Detail è uno stato che dipende dallo stato del bloc PokemonBlocBloc
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

  Pokemon? _lastLoadedPokemon;
  String? _selectedFormName;
  String? _currentType1;
  String? _currentType2;
  String? _currentTypeImage1;
  String? _currentTypeImage2;
  String? _currentArtworkDefault;
  String? _currentArtworkShiny;
  String? _currentSpriteDefault;
  String? _currentSpriteShiny;
  bool _isLoadingForm = false;

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

  Future<void> _onFormSelected(PokemonForm form) async {
    if (form.name == _selectedFormName) return;

    if (form.name == _lastLoadedPokemon?.name) {
      setState(() {
        _selectedFormName = _lastLoadedPokemon!.name;
        _currentType1 = _lastLoadedPokemon!.type1;
        _currentType2 = _lastLoadedPokemon!.type2;
        _currentTypeImage1 = _lastLoadedPokemon!.typeImage1;
        _currentTypeImage2 = _lastLoadedPokemon!.typeImage2;
        _currentArtworkDefault = _lastLoadedPokemon!.officialArtworkDefault;
        _currentArtworkShiny = _lastLoadedPokemon!.officialArtworkShiny;
        _currentSpriteDefault = _lastLoadedPokemon!.sprite;
        _currentSpriteShiny = _lastLoadedPokemon!.spriteFrontShiny;
      });
      return;
    }

    setState(() {
      _isLoadingForm = true;
    });

    final repository = getIt<IPokemonRepository>();
    final result = await repository.getFormDetails(form.url);

    if (mounted) {
      setState(() {
        _isLoadingForm = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load form: ${failure.message}')),
          );
        },
        (details) {
          setState(() {
            _selectedFormName = details.name;
            _currentType1 = details.type1;
            _currentType2 = details.type2;
            _currentTypeImage1 = details.typeImage1;
            _currentTypeImage2 = details.typeImage2;
            _currentArtworkDefault = details.artworkDefault;
            _currentArtworkShiny = details.artworkShiny;
            _currentSpriteDefault = details.spriteDefault;
            _currentSpriteShiny = details.spriteShiny;
          });
        },
      );
    }
  }

  void _showFormSelectionBottomSheet(BuildContext context, Pokemon pokemon, Color typeColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.t().formSelectorTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    secondary: Icon(
                      _showShiny ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    title: Text(
                      context.t().formSelectorShiny,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _showShiny,
                    activeThumbColor: typeColor,
                    onChanged: (val) {
                      setModalState(() {
                        _showShiny = val;
                      });
                      setState(() {
                        _showShiny = val;
                      });
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    context.t().formSelectorForms,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingForm)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pokemon.forms.length,
                        itemBuilder: (context, index) {
                          final form = pokemon.forms[index];
                          final isSelected = form.name == _selectedFormName;
                          final displayFormName = form.name
                              .replaceAll('-', ' ')
                              .split(' ')
                              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                              .join(' ');

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: InkWell(
                              onTap: () async {
                                setModalState(() {
                                  _isLoadingForm = true;
                                });
                                await _onFormSelected(form);
                                setModalState(() {
                                  _isLoadingForm = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? typeColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? typeColor : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      displayFormName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? typeColor : null,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: typeColor,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
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

          if (_lastLoadedPokemon != pokemon) {
            _lastLoadedPokemon = pokemon;
            _selectedFormName = pokemon.name;
            _currentType1 = pokemon.type1;
            _currentType2 = pokemon.type2;
            _currentTypeImage1 = pokemon.typeImage1;
            _currentTypeImage2 = pokemon.typeImage2;
            _currentArtworkDefault = pokemon.officialArtworkDefault;
            _currentArtworkShiny = pokemon.officialArtworkShiny;
            _currentSpriteDefault = pokemon.sprite;
            _currentSpriteShiny = pokemon.spriteFrontShiny;
          }

          final backgroundHelper = DetailBackgroundColor(
            type1: _currentType1 ?? pokemon.type1,
            type2: _currentType2 ?? pokemon.type2,
          );

          // Carica l'audio solo se il cry è cambiato
          _setupAudioIfNeeded(pokemon.cry);
          Color typeColor = backgroundHelper.colorFromType();
          Color textColor = itemColorExtractor(typeColor);

          final normalImage = _currentArtworkDefault ?? _currentSpriteDefault ?? pokemon.officialArtworkDefault ?? pokemon.sprite;
          final shinyImage = _currentArtworkShiny ?? _currentSpriteShiny ?? pokemon.officialArtworkShiny ?? pokemon.spriteFrontShiny ?? pokemon.sprite;

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
                                  _selectedFormName == null
                                      ? ''
                                      : '${_selectedFormName![0].toUpperCase()}${_selectedFormName!.substring(1)}',
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
                              TypeImage(type: _currentTypeImage1 ?? pokemon.typeImage1),
                              if ((_currentTypeImage2 ?? pokemon.typeImage2).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                TypeImage(type: _currentTypeImage2 ?? pokemon.typeImage2),
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
                                        icon: const Icon(
                                            Icons.backpack_outlined),
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
                              onTap: () => _showFormSelectionBottomSheet(context, pokemon, typeColor, textColor),
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
                                    firstChild: SpriteBoxImage(sprite: normalImage),
                                    secondChild: SpriteBoxImage(sprite: shinyImage),
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
