import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/2_application/bloc/home_bloc/home_bloc.dart';

/// Provides a [HomeBloc] to [child], with [userInput] as the initial search
/// text.
class HomePageProvider extends StatelessWidget {
  const HomePageProvider({
    super.key,
    required this.userInput,
    required this.child,
  });

  final String userInput;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => createHomeBloc(userInput), child: child);
  }
}
