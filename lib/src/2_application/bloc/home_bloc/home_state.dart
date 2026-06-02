part of 'home_bloc.dart';

@immutable
final class HomeBlocState extends Equatable {
  const HomeBlocState({
    required this.userInput,
    required this.navigateToDetail,
    required this.cacheCleared,
    this.errorMessage,
  });

  factory HomeBlocState.initial() {
    return const HomeBlocState(
      userInput: '',
      navigateToDetail: false,
      cacheCleared: false,
      errorMessage: null,
    );
  }

  final String userInput;
  final bool navigateToDetail;
  final bool cacheCleared;
  final String? errorMessage;

  HomeBlocState copyWith({
    String? userInput,
    bool? navigateToDetail,
    bool? cacheCleared,
    String? errorMessage,
  }) {
    return HomeBlocState(
      userInput: userInput ?? this.userInput,
      navigateToDetail: navigateToDetail ?? this.navigateToDetail,
      cacheCleared: cacheCleared ?? this.cacheCleared,
      errorMessage: errorMessage, // Let it be null if passed as null
    );
  }

  @override
  List<Object?> get props =>
      [userInput, navigateToDetail, cacheCleared, errorMessage];
}
