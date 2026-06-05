import 'package:bloc/bloc.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/learn_method.dart';
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
    required this.versionGroups,
    required this.availableMethods,
  });

  final String searchQuery;
  final String selectedMethod;
  final String? selectedVersionGroup;
  final List<PokemonMove> filteredMoves;
  final List<PokemonMove> allMoves;

  /// Distinct version groups present in [allMoves] (stable for the cubit life).
  final List<String> versionGroups;

  /// Learn-method filter options for the selected version group, with the
  /// "all" sentinel as the first entry.
  final List<String> availableMethods;

  @override
  List<Object?> get props => [
        searchQuery,
        selectedMethod,
        selectedVersionGroup,
        filteredMoves,
        allMoves,
        versionGroups,
        availableMethods,
      ];

  DetailMovesState copyWith({
    String? searchQuery,
    String? selectedMethod,
    String? selectedVersionGroup,
    List<PokemonMove>? filteredMoves,
    List<PokemonMove>? allMoves,
    List<String>? versionGroups,
    List<String>? availableMethods,
  }) {
    return DetailMovesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedVersionGroup: selectedVersionGroup ?? this.selectedVersionGroup,
      filteredMoves: filteredMoves ?? this.filteredMoves,
      allMoves: allMoves ?? this.allMoves,
      versionGroups: versionGroups ?? this.versionGroups,
      availableMethods: availableMethods ?? this.availableMethods,
    );
  }
}

/// Cubit that filters and sorts a Pokémon's moves by version group,
/// learn method, and search query.
class DetailMovesCubit extends Cubit<DetailMovesState> {
  DetailMovesCubit({
    required List<PokemonMove> moves,
    required EnLogger logger,
  })  : _logger = logger,
        super(_initialState(moves)) {
    _filterMoves();
  }

  final EnLogger _logger;
  static const _prefix = 'DetailMovesCubit';

  /// Filter sentinel that selects moves of any learn method.
  static const allMethodsFilter = 'all';

  /// Version group preferred as the initial selection when available.
  static const _preferredVersionGroup = 'diamond-pearl';

  /// Language code that triggers Italian move-name translation.
  static const _italianLanguageCode = 'it';

  /// Language code used when none is supplied.
  static const _defaultLanguageCode = 'en';

  static DetailMovesState _initialState(List<PokemonMove> moves) {
    final versionGroups = moves.map((m) => m.versionGroup).toSet().toList();
    String? initialVersionGroup;
    if (versionGroups.isNotEmpty) {
      initialVersionGroup = versionGroups.contains(_preferredVersionGroup)
          ? _preferredVersionGroup
          : versionGroups.first;
    }
    return DetailMovesState(
      searchQuery: '',
      selectedMethod: allMethodsFilter,
      selectedVersionGroup: initialVersionGroup,
      filteredMoves: const [],
      allMoves: moves,
      versionGroups: versionGroups,
      availableMethods: _availableMethodsFor(moves, initialVersionGroup),
    );
  }

  /// Learn-method options for [versionGroup], with [allMethodsFilter] first.
  static List<String> _availableMethodsFor(
      List<PokemonMove> moves, String? versionGroup) {
    if (versionGroup == null) return const [allMethodsFilter];
    final methods = moves
        .where((m) => m.versionGroup == versionGroup)
        .map((m) => m.learnMethod)
        .toSet();
    return [allMethodsFilter, ...methods];
  }

  void updateSearchQuery(String query, String languageCode) {
    emit(state.copyWith(searchQuery: query));
    _filterMoves(languageCode: languageCode);
  }

  void updateSelectedMethod(String method, String languageCode) {
    _logger.info('Method filter changed to "$method"', prefix: _prefix);
    emit(state.copyWith(selectedMethod: method));
    _filterMoves(languageCode: languageCode);
  }

  void updateSelectedVersionGroup(String versionGroup, String languageCode) {
    _logger.info('Version group changed to "$versionGroup"', prefix: _prefix);
    final availableMethods = _availableMethodsFor(state.allMoves, versionGroup);
    final selectedMethod = state.selectedMethod != allMethodsFilter &&
            !availableMethods.contains(state.selectedMethod)
        ? allMethodsFilter
        : state.selectedMethod;

    emit(state.copyWith(
      selectedVersionGroup: versionGroup,
      availableMethods: availableMethods,
      selectedMethod: selectedMethod,
    ));

    _filterMoves(languageCode: languageCode);
  }

  void _filterMoves({String languageCode = _defaultLanguageCode}) {
    final uniqueMoves = <String, PokemonMove>{};
    for (final move in state.allMoves) {
      if (move.versionGroup != state.selectedVersionGroup) continue;

      String translatedName = move.name;
      if (languageCode == _italianLanguageCode) {
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
      if (state.selectedMethod != allMethodsFilter &&
          move.learnMethod != state.selectedMethod) {
        continue;
      }

      final existing = uniqueMoves[move.name];
      if (existing == null ||
          move.levelLearnedAt > 0 &&
              (existing.levelLearnedAt == 0 ||
                  move.levelLearnedAt < existing.levelLearnedAt)) {
        uniqueMoves[move.name] = move;
      }
    }

    final filteredMoves = uniqueMoves.values.toList();
    _logger.debug('Filtered ${filteredMoves.length} moves', prefix: _prefix);

    filteredMoves.sort((a, b) {
      if (a.learnMethod == LearnMethod.levelUp.apiValue &&
          b.learnMethod == LearnMethod.levelUp.apiValue) {
        return a.levelLearnedAt.compareTo(b.levelLearnedAt);
      }
      return a.name.compareTo(b.name);
    });

    emit(state.copyWith(filteredMoves: filteredMoves));
  }
}
