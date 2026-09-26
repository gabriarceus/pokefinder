part of 'home_bloc.dart';

/// A request to open the detail of [nameOrId].
///
/// Compared by identity: two searches for the same name are two requests.
class SearchNavigation {
  // Not const: canonicalized instances would compare equal.
  SearchNavigation(this.nameOrId);

  final String nameOrId;
}

@immutable
final class HomeBlocState extends Equatable {
  const HomeBlocState({
    required this.userInput,
    this.pokemonIndex = const [],
    this.isIndexLoading = false,
    this.searchFailure,
    this.indexFailure,
    this.pendingNavigation,
  });

  factory HomeBlocState.initial() => const HomeBlocState(userInput: '');

  static const _unset = Object();

  final String userInput;
  final List<PokemonIndexEntry> pokemonIndex;
  final bool isIndexLoading;

  /// Validation failure of the last submitted search.
  final PokemonFailure? searchFailure;

  /// Failure of the last index load.
  final PokemonFailure? indexFailure;

  /// Latest valid search, still to be opened by the UI.
  final SearchNavigation? pendingNavigation;

  HomeBlocState copyWith({
    String? userInput,
    List<PokemonIndexEntry>? pokemonIndex,
    bool? isIndexLoading,
    Object? searchFailure = _unset,
    Object? indexFailure = _unset,
    SearchNavigation? pendingNavigation,
  }) {
    return HomeBlocState(
      userInput: userInput ?? this.userInput,
      pokemonIndex: pokemonIndex ?? this.pokemonIndex,
      isIndexLoading: isIndexLoading ?? this.isIndexLoading,
      searchFailure: identical(searchFailure, _unset)
          ? this.searchFailure
          : searchFailure as PokemonFailure?,
      indexFailure: identical(indexFailure, _unset)
          ? this.indexFailure
          : indexFailure as PokemonFailure?,
      pendingNavigation: pendingNavigation ?? this.pendingNavigation,
    );
  }

  @override
  List<Object?> get props => [
    userInput,
    pokemonIndex,
    isIndexLoading,
    searchFailure,
    indexFailure,
    pendingNavigation,
  ];
}
