import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_load/pokemon_load.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// In-memory selection of Pokémon for side-by-side comparison, with the
/// details of each one.
///
/// Holds at most [kComparisonMaxEntries] entries. A failure on one entry
/// never affects the other. Nothing is persisted.
class ComparisonState extends Equatable {
  const ComparisonState({this.entries = const [], this.details = const {}});

  /// Currently selected entries in insertion order.
  final List<PokemonSummary> entries;

  /// Details of each entry, keyed by [PokemonSummary.id].
  final Map<int, PokemonLoad> details;

  bool get isEmpty => entries.isEmpty;
  bool get isFull => entries.length >= kComparisonMaxEntries;

  /// Checks whether [id] is already selected.
  bool isSelected(int id) => entries.any((entry) => entry.id == id);

  /// Details of [entry]; loading until the first result arrives.
  PokemonLoad detailOf(PokemonSummary entry) =>
      details[entry.id] ?? const PokemonLoading();

  ComparisonState copyWith({
    List<PokemonSummary>? entries,
    Map<int, PokemonLoad>? details,
  }) {
    return ComparisonState(
      entries: entries ?? this.entries,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [entries, details];
}

/// Manages the comparison selection and loads the details of each entry.
@lazySingleton
class ComparisonCubit extends Cubit<ComparisonState> {
  ComparisonCubit(this._logger, this._repository)
    : super(const ComparisonState());

  static const _prefix = 'ComparisonCubit';
  final EnLogger _logger;
  final IPokemonRepository _repository;

  /// Convenience check for whether [id] is selected.
  bool isSelected(int id) => state.isSelected(id);

  /// Adds [entry] and loads its details; duplicates and entries beyond the
  /// cap are ignored.
  ///
  /// Returns true when the entry was added.
  bool addEntry(PokemonSummary entry) {
    if (state.isSelected(entry.id)) return false;
    if (state.isFull) {
      _logger.info(
        'Comparison full, ignoring ${entry.name} (#${entry.id})',
        prefix: _prefix,
      );
      return false;
    }
    _logger.info(
      'Adding comparison entry: ${entry.name} (#${entry.id})',
      prefix: _prefix,
    );
    emit(state.copyWith(entries: [...state.entries, entry]));
    loadDetails(entry);
    return true;
  }

  /// Loads the details of [entry], replacing a previous failure.
  Future<void> loadDetails(PokemonSummary entry) async {
    _setDetail(entry.id, const PokemonLoading());
    final result = await _repository.getPokemon(PokemonName(entry.name));
    if (isClosed || !state.isSelected(entry.id)) return;
    result.fold((failure) {
      _logger.error(
        'Failed to load ${entry.name} for comparison: $failure',
        prefix: _prefix,
      );
      _setDetail(entry.id, PokemonLoadFailed(failure));
    }, (pokemon) => _setDetail(entry.id, PokemonLoaded(pokemon)));
  }

  /// Removes the entry with [id], if present.
  void removeEntry(int id) {
    if (!state.isSelected(id)) return;
    _logger.info('Removing comparison entry ID: $id', prefix: _prefix);
    emit(
      ComparisonState(
        entries: state.entries.where((entry) => entry.id != id).toList(),
        details: {...state.details}..remove(id),
      ),
    );
  }

  /// Toggles [entry]; returns true when it ends up selected.
  bool toggleEntry(PokemonSummary entry) {
    if (state.isSelected(entry.id)) {
      removeEntry(entry.id);
      return false;
    }
    return addEntry(entry);
  }

  /// Removes all selected entries.
  void clear() {
    if (state.isEmpty) return;
    _logger.info('Clearing comparison entries', prefix: _prefix);
    emit(const ComparisonState());
  }

  void _setDetail(int id, PokemonLoad detail) {
    emit(state.copyWith(details: {...state.details, id: detail}));
  }
}
