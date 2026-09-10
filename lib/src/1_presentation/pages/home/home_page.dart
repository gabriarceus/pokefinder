import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/home_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

import '_app_bar.dart';
import '_bloc.dart';
import '_drawer.dart';

export '_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initialInput = context.read<HomeBloc>().state.userInput;
    if (initialInput.isNotEmpty) {
      _controller.text = initialInput;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(BuildContext context, [String? query]) {
    final rawInput = (query ?? _controller.text).trim();
    if (_isSubmitting || rawInput.isEmpty) return;
    final bloc = context.read<HomeBloc>();
    if (bloc.state.userInput != rawInput) {
      bloc.add(UserInputEvent(rawInput));
    }
    bloc.add(IsButtonPressedEvent());
  }

  void _onListen(BuildContext context, HomeBlocState state) async {
    final failure = state.failure;
    if (failure != null) {
      final showSnackBar = switch (failure) {
        BadRequestFailure() => false,
        UnauthorizedFailure() ||
        PokemonNotFoundFailure() ||
        NetworkUnavailableFailure() ||
        RequestTimeoutFailure() ||
        RateLimitedFailure() ||
        ServerFailure() ||
        InvalidResponseFailure() ||
        StorageFailure() ||
        UnexpectedFailure() => true,
      };
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.localizedMessage(context))),
        );
      }
    } else if (state.navigateToDetail && !_isSubmitting) {
      if (mounted) {
        setState(() {
          _isSubmitting = true;
        });
      }
      final nameOrId = state.userInput.trim();
      context.read<HomeBloc>().add(NavigationDoneEvent());
      try {
        await context.push('/pokemon/${Uri.encodeComponent(nameOrId)}');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: BlocListener<HomeBloc, HomeBlocState>(
        listener: _onListen,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            final pokeballDimension = isLandscape
                ? (constraints.maxHeight * 0.28).clamp(60.0, 120.0)
                : (constraints.maxHeight * 0.25).clamp(80.0, 200.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: HomeBlocBuilder(
                  builder: (context, state) {
                    final isSubmitDisabled =
                        _isSubmitting || state.userInput.trim().isEmpty;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: PokeTextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              allNames: state.allPokemonNames,
                              nameIndexFailure: state.nameIndexFailure,
                              errorText: state.failure?.localizedMessage(
                                context,
                              ),
                              onRetryIndex: () {
                                context.read<HomeBloc>().add(
                                  FetchAllPokemonNamesEvent(),
                                );
                              },
                              onChanged: (input) {
                                context.read<HomeBloc>().add(
                                  UserInputEvent(input),
                                );
                              },
                              onSubmitted: (query) {
                                _submitSearch(context, query);
                              },
                            ),
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140,
                            minHeight: 48,
                          ),
                          child: ElevatedButton(
                            onPressed: isSubmitDisabled
                                ? null
                                : () => _submitSearch(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.brandRed,
                              minimumSize: const Size(140, 48),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppPalette.onBrandRed,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context).searchButton,
                                    style: const TextStyle(
                                      color: AppPalette.onBrandRed,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: (constraints.maxHeight * 0.08).clamp(
                            16.0,
                            64.0,
                          ),
                        ),
                        ExcludeSemantics(
                          child: PokeBallWidget(
                            color: AppPalette.pokeballAccent,
                            opacity: 1.0,
                            size: Size(pokeballDimension, pokeballDimension),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
