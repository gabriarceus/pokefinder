part of 'home_bloc.dart';

@immutable
final class HomeBlocState extends Equatable {
  const HomeBlocState({
    required this.userInput,
    required this.navigateToDetail,
    required this.cacheCleared,
    this.failure,
  });

  factory HomeBlocState.initial() {
    return const HomeBlocState(
      userInput: '',
      navigateToDetail: false,
      cacheCleared: false,
      failure: null,
    );
  }

  final String userInput;
  final bool navigateToDetail;
  final bool cacheCleared;
  final PokemonFailure? failure;

  HomeBlocState copyWith({
    String? userInput,
    bool? navigateToDetail,
    bool? cacheCleared,
    PokemonFailure? failure,
  }) {
    return HomeBlocState(
      userInput: userInput ?? this.userInput,
      navigateToDetail: navigateToDetail ?? this.navigateToDetail,
      cacheCleared: cacheCleared ?? this.cacheCleared,
      failure: failure, // Let it be null if passed as null
    );
  }

  @override
  List<Object?> get props =>
      [userInput, navigateToDetail, cacheCleared, failure];
}
