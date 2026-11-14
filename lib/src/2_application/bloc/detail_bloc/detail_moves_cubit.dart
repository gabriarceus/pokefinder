import 'package:bloc/bloc.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_state.dart';
import 'package:pokefinder/src/2_application/helpers/move_name_resolver.dart';
import 'package:pokefinder/src/3_domain/entities/learn_method.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/game_version_mappings.dart';

/// Holds the current search, filter, and move list state for the moves tab.
class DetailMovesState extends Equatable {
  const DetailMovesState({
    required this.searchQuery,
    required this.selectedMethod,
    required this.selectedVersionGroup,
    required this.filteredMoves,
    required this.availableMethods,
  });

  final String searchQuery;
  final String selectedMethod;
  final String? selectedVersionGroup;
  final List<PokemonMove> filteredMoves;

  /// Learn-method filter options for the selected version group, with the
  /// "all" sentinel as the first entry.
  final List<String> availableMethods;

  @override
  List<Object?> get props => [
    searchQuery,
    selectedMethod,
    selectedVersionGroup,
    filteredMoves,
    availableMethods,
  ];

  DetailMovesState copyWith({
    String? searchQuery,
    String? selectedMethod,
    String? selectedVersionGroup,
    List<PokemonMove>? filteredMoves,
    List<String>? availableMethods,
  }) {
    return DetailMovesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedVersionGroup: selectedVersionGroup ?? this.selectedVersionGroup,
      filteredMoves: filteredMoves ?? this.filteredMoves,
      availableMethods: availableMethods ?? this.availableMethods,
    );
  }
}

/// Cubit that filters and sorts a Pokémon's moves by game version,
/// learn method, and search query.
class DetailMovesCubit extends Cubit<DetailMovesState> {
  /// Starts on the version group of [gameVersion]; see [selectGameVersion].
  DetailMovesCubit({
    required List<PokemonMove> moves,
    required MoveNameResolver moveName,
    required EnLogger logger,
    String gameVersion = DetailGameVersionState.allVersions,
  }) : _moves = moves,
       _moveName = moveName,
       _logger = logger,
       super(
         const DetailMovesState(
           searchQuery: '',
           selectedMethod: allMethodsFilter,
           selectedVersionGroup: null,
           filteredMoves: [],
           availableMethods: [allMethodsFilter],
         ),
       ) {
    selectGameVersion(gameVersion);
  }

  final List<PokemonMove> _moves;
  final MoveNameResolver _moveName;
  final EnLogger _logger;
  static const _prefix = 'DetailMovesCubit';

  /// Filter sentinel that selects moves of any learn method.
  static const allMethodsFilter = 'all';

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _filterMoves();
  }

  void updateSelectedMethod(String method) {
    _logger.info('Method filter changed to "$method"', prefix: _prefix);
    emit(state.copyWith(selectedMethod: method));
    _filterMoves();
  }

  /// Shows the moves of the version group that contains [gameVersion].
  ///
  /// [DetailGameVersionState.allVersions] selects the most recent version
  /// group of the Pokémon.
  void selectGameVersion(String gameVersion) {
    final versionGroup = gameVersion == DetailGameVersionState.allVersions
        ? GameVersionMappings.latestVersionGroup(
                _moves.map((m) => m.versionGroup),
              ) ??
              _moves.firstOrNull?.versionGroup
        : GameVersionMappings.versionGroupFor(gameVersion);
    _logger.info('Version group changed to "$versionGroup"', prefix: _prefix);

    final methods = {
      for (final move in _moves)
        if (move.versionGroup == versionGroup) move.learnMethod,
    };
    final availableMethods = [allMethodsFilter, ...methods];
    final selectedMethod = availableMethods.contains(state.selectedMethod)
        ? state.selectedMethod
        : allMethodsFilter;

    emit(
      DetailMovesState(
        searchQuery: state.searchQuery,
        selectedMethod: selectedMethod,
        selectedVersionGroup: versionGroup,
        filteredMoves: state.filteredMoves,
        availableMethods: availableMethods,
      ),
    );
    _filterMoves();
  }

  void _filterMoves() {
    final query = state.searchQuery.toLowerCase();
    final uniqueMoves = <String, PokemonMove>{};
    for (final move in _moves) {
      if (move.versionGroup != state.selectedVersionGroup) continue;
      if (state.selectedMethod != allMethodsFilter &&
          move.learnMethod != state.selectedMethod) {
        continue;
      }
      final matchesSearch =
          move.name.toLowerCase().contains(query) ||
          _moveName(move.name).toLowerCase().contains(query);
      if (!matchesSearch) continue;

      final existing = uniqueMoves[move.name];
      if (existing == null ||
          move.levelLearnedAt > 0 &&
              (existing.levelLearnedAt == 0 ||
                  move.levelLearnedAt < existing.levelLearnedAt)) {
        uniqueMoves[move.name] = move;
      }
    }

    final names = {for (final name in uniqueMoves.keys) name: _moveName(name)};
    final filteredMoves = uniqueMoves.values.toList()
      ..sort((a, b) {
        final byMethod = _methodRank(a).compareTo(_methodRank(b));
        if (byMethod != 0) return byMethod;
        if (_isLevelUp(a)) {
          final byLevel = a.levelLearnedAt.compareTo(b.levelLearnedAt);
          if (byLevel != 0) return byLevel;
        }
        final byName = names[a.name]!.compareTo(names[b.name]!);
        return byName != 0 ? byName : a.name.compareTo(b.name);
      });

    _logger.debug('Filtered ${filteredMoves.length} moves', prefix: _prefix);
    emit(state.copyWith(filteredMoves: filteredMoves));
  }

  static bool _isLevelUp(PokemonMove move) =>
      move.learnMethod == LearnMethod.levelUp.apiValue;

  /// Known learn methods in [LearnMethod] order, then every other method.
  static int _methodRank(PokemonMove move) =>
      LearnMethod.fromApi(move.learnMethod)?.index ?? LearnMethod.values.length;
}
