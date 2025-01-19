part of 'home_bloc_bloc.dart';

@immutable
final class HomeBlocState {

  final String userInput;
  final Option<Either<Failure,void>> optionFailureOrPokemonFound;
  
  const HomeBlocState({
    required this.userInput,
    required this.optionFailureOrPokemonFound,
  });

  factory HomeBlocState.initial() {
    return  HomeBlocState(optionFailureOrPokemonFound: none(), userInput: '');
  }

  HomeBlocState copyWith({
    String? userInput,
    Option<Either<Failure,Unit>>? optionFailureOrPokemonFound,
  }) {

    return HomeBlocState(
      optionFailureOrPokemonFound: optionFailureOrPokemonFound ?? none(),
      userInput: userInput ?? this.userInput,
    );
  }


}
