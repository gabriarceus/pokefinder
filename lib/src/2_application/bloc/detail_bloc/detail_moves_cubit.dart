import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/l10n/moves_db.dart';

/// Holds the current search, filter, and move list state for the moves tab.
class DetailMovesState extends Equatable {
  const DetailMovesState({
    required this.searchQuery,
    required this.selectedMethod,
    required this.selectedVersionGroup,
    required this.filteredMoves,
    required this.allMoves,
  });

  final String searchQuery;
  final String selectedMethod;
  final String? selectedVersionGroup;
  final List<PokemonMove> filteredMoves;
  final List<PokemonMove> allMoves;

  @override
  List<Object?> get props => [
        searchQuery,
        selectedMethod,
        selectedVersionGroup,
        filteredMoves,
        allMoves,
      ];

  DetailMovesState copyWith({
    String? searchQuery,
    String? selectedMethod,
    String? selectedVersionGroup,
    List<PokemonMove>? filteredMoves,
    List<PokemonMove>? allMoves,
  }) {
    return DetailMovesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedVersionGroup: selectedVersionGroup ?? this.selectedVersionGroup,
      filteredMoves: filteredMoves ?? this.filteredMoves,
      allMoves: allMoves ?? this.allMoves,
    );
  }
}

/// Cubit that filters and sorts a Pokémon's moves by version group,
/// learn method, and search query.
class DetailMovesCubit extends Cubit<DetailMovesState> {
  DetailMovesCubit({
    required List<PokemonMove> moves,
  }) : super(_initialState(moves)) {
    _filterMoves();
  }

  static DetailMovesState _initialState(List<PokemonMove> moves) {
    final versionGroups = moves.map((m) => m.versionGroup).toSet().toList();
    String? initialVersionGroup;
    if (versionGroups.isNotEmpty) {
      if (versionGroups.contains('diamond-pearl')) {
        initialVersionGroup = 'diamond-pearl';
      } else {
        initialVersionGroup = versionGroups.first;
      }
    }
    return DetailMovesState(
      searchQuery: '',
      selectedMethod: 'all',
      selectedVersionGroup: initialVersionGroup,
      filteredMoves: const [],
      allMoves: moves,
    );
  }

  void updateSearchQuery(String query, String languageCode) {
    emit(state.copyWith(searchQuery: query));
    _filterMoves(languageCode: languageCode);
  }

  void updateSelectedMethod(String method, String languageCode) {
    emit(state.copyWith(selectedMethod: method));
    _filterMoves(languageCode: languageCode);
  }

  void updateSelectedVersionGroup(String versionGroup, String languageCode) {
    emit(state.copyWith(selectedVersionGroup: versionGroup));

    final availableMethods = state.allMoves
        .where((m) => m.versionGroup == versionGroup)
        .map((m) => m.learnMethod)
        .toSet();

    if (state.selectedMethod != 'all' &&
        !availableMethods.contains(state.selectedMethod)) {
      emit(state.copyWith(selectedMethod: 'all'));
    }

    _filterMoves(languageCode: languageCode);
  }

  List<String> getAvailableMethods() {
    final versionGroup = state.selectedVersionGroup;
    if (versionGroup == null) return ['all'];
    final methodsSet = state.allMoves
        .where((m) => m.versionGroup == versionGroup)
        .map((m) => m.learnMethod)
        .toSet();
    return ['all', ...methodsSet];
  }

  void _filterMoves({String languageCode = 'en'}) {
    final uniqueMoves = <String, PokemonMove>{};
    for (final move in state.allMoves) {
      if (move.versionGroup != state.selectedVersionGroup) continue;

      String translatedName = move.name;
      if (languageCode == 'it') {
        final key = move.name.toLowerCase().trim();
        final trans = movesDb[key];
        if (trans != null) {
          translatedName = trans;
        }
      }
      translatedName = translatedName.toLowerCase();

      final matchesSearch =
          move.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
              translatedName.contains(state.searchQuery.toLowerCase());

      if (!matchesSearch) continue;
      if (state.selectedMethod != 'all' &&
          move.learnMethod != state.selectedMethod) continue;

      final existing = uniqueMoves[move.name];
      if (existing == null ||
          move.levelLearnedAt > 0 &&
              (existing.levelLearnedAt == 0 ||
                  move.levelLearnedAt < existing.levelLearnedAt)) {
        uniqueMoves[move.name] = move;
      }
    }

    final filteredMoves = uniqueMoves.values.toList();

    filteredMoves.sort((a, b) {
      if (a.learnMethod == 'level-up' && b.learnMethod == 'level-up') {
        return a.levelLearnedAt.compareTo(b.levelLearnedAt);
      }
      return a.name.compareTo(b.name);
    });

    emit(state.copyWith(filteredMoves: filteredMoves));
  }
}
