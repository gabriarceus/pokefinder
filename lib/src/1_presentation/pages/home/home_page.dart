import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/presentation.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/home_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onListen(BuildContext context, HomeBlocState state) {
    final failure = state.failure;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context))),
      );
    } else if (state.navigateToDetail) {
      context.go('/detail', extra: {'pokemonName': state.userInput});
      context.read<HomeBloc>().add(NavigationDoneEvent());
    }
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
                      child: Text(AppLocalizations.of(context).searchButton,
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
