import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/business_logic/bloc/home_bloc/home_bloc.dart';
import 'package:pokefinder/pages/home/_app_bar.dart';
import 'package:pokefinder/pages/home/_bloc.dart';
import 'package:pokefinder/widgets/home/poke_text_field.dart';
import 'package:pokefinder/widgets/home/pokeball_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  void _onListen(BuildContext context, HomeBlocState state) {
    state.optionFailureOrPokemonFound.fold(
      () => null,
      (either) => either.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failure.map(
                  onBadRequest: (_) => "onBadRequest",
                  onFailure: (_) => "onFailure",
                  onOther: (_) => "onOther",
                ),
              ),
            ),
          );
        },
        (_) => context.go('/detail', extra: {'pokemonName': state.userInput}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // or else it shows an error
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: BlocListener<HomeBloc, HomeBlocState>(
        listener: _onListen,

        // When the search button is pressed with !previous.pokemonFound && current.pokemonFound I can't perform a new search
        child: HomeBlocBuilder(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0, bottom: 16.0),
                      child: SizedBox(
                        width: 200,
                        child: PokeTextField(
                          controller: _controller,
                          onChanged: (input) {
                            context.read<HomeBloc>().add(UserInputEvent(input));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(IsButtonPressedEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Set the background color to red
                      ),
                      child: Text(AppLocalizations.of(context)!.searchButton,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                const PokeBallWidget(
                  color: Color.fromARGB(255, 223, 112, 104),
                  opacity: 1.0,
                  size: Size(200, 200),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
