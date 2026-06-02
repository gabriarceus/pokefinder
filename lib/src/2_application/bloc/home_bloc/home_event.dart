part of 'home_bloc.dart';

@immutable
sealed class HomeBlocEvent {}

class UserInputEvent extends HomeBlocEvent {
  UserInputEvent(this.userInput);

  final String userInput;

  String? get input => userInput;
}

class IsButtonPressedEvent extends HomeBlocEvent {}

class ClearCacheEvent extends HomeBlocEvent {}

class NavigationDoneEvent extends HomeBlocEvent {}
