import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Maximum capacity of the recently viewed Pokémon queue.
const int kMaxRecentPokemon = 20;

/// Maximum capacity of the recent search queries list.
const int kMaxRecentSearches = 10;

/// State for recently viewed Pokémon and recent search history.
class RecentHistoryState extends Equatable {
  const RecentHistoryState({
    this.recentPokemon = const [],
    this.recentSearches = const [],
    this.isHistoryEnabled = true,
  });

  /// Bounded list of recently viewed Pokémon (maximum [kMaxRecentPokemon]).
  final List<RecentPokemon> recentPokemon;

  /// Bounded list of recent successful search query strings.
  final List<String> recentSearches;

  /// Whether recording history is active.
  final bool isHistoryEnabled;

  RecentHistoryState copyWith({
    List<RecentPokemon>? recentPokemon,
    List<String>? recentSearches,
    bool? isHistoryEnabled,
  }) {
    return RecentHistoryState(
      recentPokemon: recentPokemon ?? this.recentPokemon,
      recentSearches: recentSearches ?? this.recentSearches,
      isHistoryEnabled: isHistoryEnabled ?? this.isHistoryEnabled,
    );
  }

  @override
  List<Object?> get props => [recentPokemon, recentSearches, isHistoryEnabled];
}

/// Manages persistent bounded history for recently viewed Pokémon and searches.
@lazySingleton
class RecentHistoryCubit extends HydratedCubit<RecentHistoryState> {
  RecentHistoryCubit(this._logger, {Clock clock = const Clock()})
    : _clock = clock,
      super(const RecentHistoryState());

  static const _prefix = 'RecentHistoryCubit';
  final EnLogger _logger;
  final Clock _clock;

  /// Records a viewed Pokémon, moving it to the front if revisited and evicting beyond [kMaxRecentPokemon].
  void addRecentPokemon({
    required int id,
    required String name,
    required String spriteUrl,
    List<PokemonType> types = const [],
  }) {
    if (!state.isHistoryEnabled) return;

    _logger.info('Recording recent Pokemon: $name (#$id)', prefix: _prefix);
    final entry = RecentPokemon(
      id: id,
      name: name,
      spriteUrl: spriteUrl,
      types: types,
      viewedAt: _clock.now(),
    );

    final updated = List<RecentPokemon>.from(state.recentPokemon)
      ..removeWhere((item) => item.id == id)
      ..insert(0, entry);

    if (updated.length > kMaxRecentPokemon) {
      updated.removeRange(kMaxRecentPokemon, updated.length);
    }

    emit(state.copyWith(recentPokemon: updated));
  }

  /// Records a search query, moving it to the front and evicting beyond [kMaxRecentSearches].
  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (!state.isHistoryEnabled || trimmed.isEmpty) return;

    final updated = List<String>.from(state.recentSearches)
      ..removeWhere((s) => s.toLowerCase() == trimmed.toLowerCase())
      ..insert(0, trimmed);

    if (updated.length > kMaxRecentSearches) {
      updated.removeRange(kMaxRecentSearches, updated.length);
    }

    emit(state.copyWith(recentSearches: updated));
  }

  /// Removes a single Pokémon from recently viewed history.
  void removeRecentPokemon(int id) {
    final updated = state.recentPokemon.where((item) => item.id != id).toList();
    emit(state.copyWith(recentPokemon: updated));
  }

  /// Removes a single query from search history.
  void removeRecentSearch(String query) {
    final updated = state.recentSearches
        .where((s) => s.toLowerCase() != query.trim().toLowerCase())
        .toList();
    emit(state.copyWith(recentSearches: updated));
  }

  /// Clears recently viewed Pokémon history.
  void clearRecentPokemon() {
    emit(state.copyWith(recentPokemon: const []));
  }

  /// Clears recent search queries.
  void clearRecentSearches() {
    emit(state.copyWith(recentSearches: const []));
  }

  /// Clears all viewing and search history.
  void clearAllHistory() {
    emit(state.copyWith(recentPokemon: const [], recentSearches: const []));
  }

  /// Enables or pauses history recording.
  void setHistoryEnabled(bool enabled) {
    _logger.info(
      'Setting history recording enabled: $enabled',
      prefix: _prefix,
    );
    emit(state.copyWith(isHistoryEnabled: enabled));
  }

  @override
  RecentHistoryState fromJson(Map<String, dynamic> json) {
    final rawPokemon = json['recentPokemon'] as List<dynamic>? ?? const [];
    final recentPokemon = rawPokemon
        .whereType<Map<String, dynamic>>()
        .map(RecentPokemon.fromJson)
        .toList();
    final rawSearches = json['recentSearches'] as List<dynamic>? ?? const [];
    final recentSearches = rawSearches.map((e) => e.toString()).toList();
    final isEnabled = json['isHistoryEnabled'] as bool? ?? true;

    return RecentHistoryState(
      recentPokemon: recentPokemon,
      recentSearches: recentSearches,
      isHistoryEnabled: isEnabled,
    );
  }

  @override
  Map<String, dynamic> toJson(RecentHistoryState state) => {
    'recentPokemon': state.recentPokemon.map((r) => r.toJson()).toList(),
    'recentSearches': state.recentSearches,
    'isHistoryEnabled': state.isHistoryEnabled,
  };
}
