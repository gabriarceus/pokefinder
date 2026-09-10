part of 'home_bloc.dart';

@immutable
final class HomeBlocState extends Equatable {
  const HomeBlocState({
    required this.userInput,
    required this.navigateToDetail,
    required this.cacheCleared,
    required this.allPokemonNames,
    this.failure,
    this.nameIndexFailure,
  });

  factory HomeBlocState.initial() {
    return const HomeBlocState(
      userInput: '',
      navigateToDetail: false,
      cacheCleared: false,
      allPokemonNames: [],
      failure: null,
      nameIndexFailure: null,
    );
  }

  static const _unset = Object();

  final String userInput;
  final bool navigateToDetail;
  final bool cacheCleared;
  final List<String> allPokemonNames;
  final PokemonFailure? failure;
  final PokemonFailure? nameIndexFailure;

  HomeBlocState copyWith({
    String? userInput,
    bool? navigateToDetail,
    bool? cacheCleared,
    List<String>? allPokemonNames,
    PokemonFailure? failure,
    Object? nameIndexFailure = _unset,
  }) {
    return HomeBlocState(
      userInput: userInput ?? this.userInput,
      navigateToDetail: navigateToDetail ?? this.navigateToDetail,
      cacheCleared: cacheCleared ?? this.cacheCleared,
      allPokemonNames: allPokemonNames ?? this.allPokemonNames,
      failure: failure, // Let it be null if passed as null
      nameIndexFailure: identical(nameIndexFailure, _unset)
          ? this.nameIndexFailure
          : nameIndexFailure as PokemonFailure?,
    );
  }

  @override
  List<Object?> get props => [
    userInput,
    navigateToDetail,
    cacheCleared,
    allPokemonNames,
    failure,
    nameIndexFailure,
  ];
}
