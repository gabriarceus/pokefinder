import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/home_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';

import '_app_bar.dart';
import '_drawer.dart';

export '_bloc.dart';

/// Maximum width of the search column.
const _kContentMaxWidth = 400.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<HomeBloc>().state.userInput;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch([String? query]) {
    final input = (query ?? _controller.text).trim();
    if (input.isEmpty) return;
    context.read<HomeBloc>().add(SearchSubmitted(input));
  }

  void _openDetail(SearchNavigation navigation) {
    // Without unfocus the field gets focus again when the user comes back,
    // and the keyboard and the suggestions cover the buttons.
    _focusNode.unfocus();
    final nameOrId = navigation.nameOrId;
    // Consume the request, so resubmitting the same term navigates again.
    context.read<HomeBloc>().add(NavigationDone());
    context.push(AppRoutes.pokemon(nameOrId, search: nameOrId));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasHistory = context.select<RecentHistoryCubit, bool>((cubit) {
      final history = cubit.state;
      return history.isHistoryEnabled &&
          (history.recentPokemon.isNotEmpty ||
              history.recentSearches.isNotEmpty);
    });

    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: BlocListener<HomeBloc, HomeBlocState>(
        listenWhen: (previous, current) =>
            current.pendingNavigation != null &&
            previous.pendingNavigation != current.pendingNavigation,
        listener: (context, state) => _openDetail(state.pendingNavigation!),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pokeballSize = (constraints.maxHeight * 0.25).clamp(
              60.0,
              200.0,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _kContentMaxWidth,
                    ),
                    child: BlocBuilder<HomeBloc, HomeBlocState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PokeTextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              allEntries: state.pokemonIndex,
                              nameIndexFailure: state.indexFailure,
                              errorText: state.searchFailure?.localizedMessage(
                                context,
                              ),
                              onRetryIndex: () =>
                                  context.read<HomeBloc>().add(LoadIndex()),
                              onChanged: (input) => context
                                  .read<HomeBloc>()
                                  .add(SearchInputChanged(input)),
                              onSubmitted: _submitSearch,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: state.userInput.trim().isEmpty
                                  ? null
                                  : _submitSearch,
                              child: Text(t.searchButton),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                _focusNode.unfocus();
                                context.push(AppRoutes.pokedex);
                              },
                              icon: const Icon(Icons.catching_pokemon),
                              label: Text(t.browsePokedex),
                            ),
                            RecentHistoryShelf(
                              onSelectQuery: (query) {
                                _controller.text = query;
                                _submitSearch(query);
                              },
                            ),
                            if (!hasHistory) ...[
                              const SizedBox(height: 48),
                              Center(
                                child: ExcludeSemantics(
                                  child: PokeBallWidget(size: pokeballSize),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
