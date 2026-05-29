import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';

class HomePageProvider extends StatelessWidget {
  /// inject [HomeBloc]
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
      create: (_) => getIt<HomeBloc>()..add(UserInputEvent(userInput)),
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
    return BlocBuilder<HomeBloc, HomeBlocState>(
      builder: builder,
    );
  }
}
