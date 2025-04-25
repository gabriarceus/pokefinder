part of 'home_bloc.dart';

@immutable
sealed class HomeBlocEvent {}

class UserInputEvent extends HomeBlocEvent {
  final String userInput;

  UserInputEvent(this.userInput);

  String? get input => userInput;
}

// The user pressed the button to perform a search
// and it should show the detail page if the input is valid
class IsButtonPressedEvent extends HomeBlocEvent {}
