part of 'home_bloc.dart';

@immutable
final class HomeBlocState extends Equatable {
  const HomeBlocState({
    required this.userInput,
    required this.navigateToDetail,
    required this.cacheCleared,
    required this.allPokemonNames,
    required this.searchSuggestions,
    this.failure,
    this.nameIndexFailure,
  });

  factory HomeBlocState.initial() {
    return const HomeBlocState(
      userInput: '',
      navigateToDetail: false,
      cacheCleared: false,
      allPokemonNames: [],
      searchSuggestions: [],
      failure: null,
      nameIndexFailure: null,
    );
  }

  static const _unset = Object();

  final String userInput;
  final bool navigateToDetail;
  final bool cacheCleared;
  final List<String> allPokemonNames;
  final List<String> searchSuggestions;
  final PokemonFailure? failure;
  final PokemonFailure? nameIndexFailure;

  HomeBlocState copyWith({
    String? userInput,
    bool? navigateToDetail,
    bool? cacheCleared,
    List<String>? allPokemonNames,
    List<String>? searchSuggestions,
    PokemonFailure? failure,
    Object? nameIndexFailure = _unset,
  }) {
    return HomeBlocState(
      userInput: userInput ?? this.userInput,
      navigateToDetail: navigateToDetail ?? this.navigateToDetail,
      cacheCleared: cacheCleared ?? this.cacheCleared,
      allPokemonNames: allPokemonNames ?? this.allPokemonNames,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
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
    searchSuggestions,
    failure,
    nameIndexFailure,
  ];
}
