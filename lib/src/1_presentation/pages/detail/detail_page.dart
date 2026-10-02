import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/add_to_team_sheet.dart';
import 'package:pokefinder/src/1_presentation/theme/readable_color.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

import '_app_bar.dart';
import '_loading.dart';
import 'failure.dart';
import 'tabs/tabs.dart';
import 'widgets/detail_header.dart';
import 'widgets/form_selection_bottom_sheet.dart';

export '_bloc.dart';

/// Height of the tab bar: a 72 dp icon-and-text tab plus the rounded top of
/// the content card.
const _kTabBarHeight = 72.0 + 8;

/// Detail screen displaying data for a single Pokémon, identified by [pokemonName].
class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({
    super.key,
    required this.pokemonName,
    this.searchQuery,
  });

  final String pokemonName;
  final String? searchQuery;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final CryAudioController _audioController = resolveCryAudioController();
  bool _showShiny = false;

  @override
  void dispose() {
    _audioController.dispose();
    super.dispose();
  }

  /// Runs once per loaded Pokémon, not on later emissions for the same one.
  void _onPokemonLoaded(BuildContext context, PokemonDetailSuccess state) {
    context.read<RecentHistoryCubit>().addRecentPokemon(state.summary);

    final query = widget.searchQuery?.trim() ?? '';
    if (query.isNotEmpty) {
      context.read<RecentHistoryCubit>().addRecentSearch(query);
    }

    final preferences = context.read<PreferencesCubit>().state;
    if (preferences.autoPlayCry && state.pokemon.cry.isNotEmpty) {
      _audioController.setVolume(preferences.cryVolume);
      _audioController.play(state.pokemon.cry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PokemonDetailBloc, PokemonDetailState>(
      listenWhen: (previous, current) =>
          current is PokemonDetailSuccess &&
          (previous is! PokemonDetailSuccess ||
              previous.pokemon.id != current.pokemon.id),
      listener: (context, state) =>
          _onPokemonLoaded(context, state as PokemonDetailSuccess),
      child: BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
        builder: (context, state) => switch (state) {
          PokemonDetailInitial() ||
          PokemonDetailLoading() => const DetailLoading(),
          PokemonDetailFailure() => DetailFailure(
            state: state,
            pokemonName: widget.pokemonName,
          ),
          PokemonDetailSuccess() => _DetailSuccessView(
            success: state,
            audioController: _audioController,
            showShiny: _showShiny,
            onShinyChanged: (value) => setState(() => _showShiny = value),
          ),
        },
      ),
    );
  }
}

class _DetailSuccessView extends StatelessWidget {
  const _DetailSuccessView({
    required this.success,
    required this.audioController,
    required this.showShiny,
    required this.onShinyChanged,
  });

  final PokemonDetailSuccess success;
  final CryAudioController audioController;
  final bool showShiny;
  final ValueChanged<bool> onShinyChanged;

  void _showFormSelectionBottomSheet(
    BuildContext context,
    Color typeColor,
    Color textColor,
  ) {
    final bloc = context.read<PokemonDetailBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: FormSelectionBottomSheet(
            pokemon: success.pokemon,
            typeColor: typeColor,
            textColor: textColor,
            showShiny: showShiny,
            onShinyChanged: onShinyChanged,
          ),
        );
      },
    );
  }

  /// Copies the canonical link for the displayed Pokémon/form to the clipboard.
  Future<void> _sharePokemonLink(BuildContext context) async {
    final link = buildPokemonCanonicalPath(success.summary.name);
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.t().shareLinkCopied)));
  }

  /// Toggles the displayed Pokémon in the side-by-side comparison selection.
  void _toggleComparison(BuildContext context) {
    final cubit = context.read<ComparisonCubit>();
    final wasSelected = cubit.isSelected(success.summary.id);
    final nowSelected = cubit.toggleEntry(success.summary);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (nowSelected) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.t().compareAdded),
          action: SnackBarAction(
            label: context.t().compareView,
            onPressed: () => context.push(AppRoutes.compare),
          ),
        ),
      );
    } else if (!wasSelected) {
      messenger.showSnackBar(SnackBar(content: Text(context.t().compareFull)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = success.pokemon;
    final formDetails = success.formDetails;
    final summary = success.summary;
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(summary.id),
    );
    final isInComparison = context.select<ComparisonCubit, bool>(
      (cubit) => cubit.isSelected(summary.id),
    );

    final typeColor = TypeColorScheme.getColorFromType(formDetails.type1);
    final textColor = contrastingTextColor(typeColor);
    final accentColor = typeColor.readableOn(Theme.of(context).brightness);
    final mediaQuery = MediaQuery.of(context);
    final headerHeight = (mediaQuery.size.height * 0.3).clamp(120.0, 220.0);

    return BlocProvider<DetailGameVersionCubit>(
      create: (_) =>
          DetailGameVersionCubit()
            ..initialize(pokemon, encounters: success.encounters),
      child: BlocListener<PokemonDetailBloc, PokemonDetailState>(
        listenWhen: (prev, curr) =>
            prev is PokemonDetailSuccess &&
            curr is PokemonDetailSuccess &&
            prev.encounters != curr.encounters,
        listener: (context, state) {
          final current = state as PokemonDetailSuccess;
          context.read<DetailGameVersionCubit>().initialize(
            current.pokemon,
            encounters: current.encounters,
          );
        },
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: DetailAppBar(
                    backgroundColor: typeColor,
                    foregroundColor: textColor,
                    expandedHeight:
                        kToolbarHeight + headerHeight + _kTabBarHeight,
                    background: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: TypeColorScheme.gradient(
                          formDetails.type1,
                          formDetails.type2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          mediaQuery.padding.top + kToolbarHeight,
                          16,
                          _kTabBarHeight + 8,
                        ),
                        child: DetailHeader(
                          selectedFormName: formDetails.name,
                          pokemonId: pokemon.id,
                          type1: formDetails.type1,
                          type2: formDetails.type2,
                          textColor: textColor,
                          showShiny: showShiny,
                          spriteDefault: formDetails.spriteDefault,
                          spriteShiny: formDetails.spriteShiny,
                        ),
                      ),
                    ),
                    bottom: _DetailTabBar(accentColor: accentColor),
                    showShiny: showShiny,
                    isStale: pokemon.isStale,
                    isFavorite: isFavorite,
                    onToggleFavorite: () => context
                        .read<FavoritesCubit>()
                        .toggleFavorite(success.summary),
                    onToggleShiny: () => onShinyChanged(!showShiny),
                    onShare: () => _sharePokemonLink(context),
                    isInComparison: isInComparison,
                    onCompare: () => _toggleComparison(context),
                    onTeam: () => showAddToTeamSheet(context, success.summary),
                  ),
                ),
              ],
              // The type color is the only accent inside the content card.
              body: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: accentColor,
                    onPrimary: contrastingTextColor(accentColor),
                    // Tonal buttons and selected chips read this role.
                    secondaryContainer: Color.alphaBlend(
                      typeColor.withValues(alpha: 0.24),
                      Theme.of(context).colorScheme.surface,
                    ),
                    onSecondaryContainer: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                  ),
                ),
                child: TabBarView(
                  children: [
                    DetailInfoTab(
                      pokemon: pokemon,
                      audioController: audioController,
                      onFormTap: () => _showFormSelectionBottomSheet(
                        context,
                        typeColor,
                        textColor,
                      ),
                      selectedFormName: formDetails.name,
                    ),
                    DetailStatsTab(pokemon: pokemon),
                    DetailMovesTab(pokemon: pokemon),
                    DetailItemsGamesTab(
                      pokemon: pokemon,
                      encounters: success.encounters,
                      isLoadingEncounters: success.isLoadingEncounters,
                      encountersFailure: success.encountersFailure,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The detail screen's tab bar on the rounded top of the content card.
class _DetailTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailTabBar({required this.accentColor});

  final Color accentColor;

  @override
  Size get preferredSize => const Size.fromHeight(_kTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t();
    final labelStyle = theme.textTheme.labelMedium;
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: TabBar(
        indicatorColor: accentColor,
        labelColor: accentColor,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: labelStyle?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: labelStyle,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: t.tabInfo, icon: const Icon(Icons.info_outline)),
          Tab(text: t.tabStats, icon: const Icon(Icons.bar_chart)),
          Tab(text: t.tabMoves, icon: const Icon(Icons.bolt)),
          Tab(text: t.tabItemsGames, icon: const Icon(Icons.category_outlined)),
        ],
      ),
    );
  }
}
