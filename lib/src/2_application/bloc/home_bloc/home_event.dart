part of 'home_bloc.dart';

@immutable
sealed class HomeBlocEvent {}

/// The search field text changed to [input].
class SearchInputChanged extends HomeBlocEvent {
  SearchInputChanged(this.input);

  final String input;
}

/// The user asked to open the Pokémon named or numbered [input].
class SearchSubmitted extends HomeBlocEvent {
  SearchSubmitted(this.input);

  final String input;
}

/// Loads the Pokémon index used for suggestions.
class LoadIndex extends HomeBlocEvent {}

/// The pending navigation request has been handled by the UI.
class NavigationDone extends HomeBlocEvent {}
