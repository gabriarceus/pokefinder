part of 'home_bloc_bloc.dart';

@immutable
sealed class HomeBlocEvent {}

//Gli eventi possibili della business logic

/// L'utente ha inserito un input nel campo di testo
class UserInputEvent extends HomeBlocEvent {
  final String userInput;

  UserInputEvent(this.userInput);

  String? get input => userInput;
}

/// L'utente ha premuto il pulsante per eseguire una ricerca
// dovrebbe mostrare la pagina di dettaglio se l'input è valido
class IsButtonPressedEvent extends HomeBlocEvent {}