import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/bloc_home/home_bloc_bloc.dart';

class HomePageProvider extends StatelessWidget {
  /// inject [HomeBlocBloc]
  ///
  /// on init add [UserInputEvent]

  const HomePageProvider({
    super.key,
    required this.userInput,
    required this.child,
  });

  final String userInput;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBlocBloc()..add(UserInputEvent(userInput)),
      child: child,
    );
  }
}

class HomeBlocBuilder extends StatelessWidget {
  const HomeBlocBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, HomeBlocState state) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBlocBloc, HomeBlocState>(
      builder: builder,
    );
  }
}
