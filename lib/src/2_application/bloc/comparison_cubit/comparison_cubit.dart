import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// In-memory selection of Pokémon entries for side-by-side comparison.
///
/// Holds lightweight index refs only (max [kComparisonMaxEntries]); full
/// details are fetched per entry by the comparison page, so a failure on one
/// side never destroys the other. Nothing is persisted: v1 is session-scoped.
class ComparisonState extends Equatable {
  const ComparisonState({this.entries = const []});

  /// Currently selected entries in insertion order (at most 2).
  final List<PokemonIndexEntry> entries;

  bool get isEmpty => entries.isEmpty;
  bool get isFull => entries.length >= kComparisonMaxEntries;
  bool get hasSingle => entries.length == 1;
  bool get canAdd => canAddToComparison(entries.length);

  /// Checks whether [id] is already selected.
  bool isSelected(int id) => entries.any((entry) => entry.id == id);

  ComparisonState copyWith({List<PokemonIndexEntry>? entries}) {
    return ComparisonState(entries: entries ?? this.entries);
  }

  @override
  List<Object?> get props => [entries];
}

/// Manages the in-memory comparison selection.
@lazySingleton
class ComparisonCubit extends Cubit<ComparisonState> {
  ComparisonCubit(this._logger) : super(const ComparisonState());

  static const _prefix = 'ComparisonCubit';
  final EnLogger _logger;

  /// Convenience check for whether [id] is selected.
  bool isSelected(int id) => state.isSelected(id);

  /// Adds [entry]; duplicates and entries beyond the cap are ignored.
  ///
  /// Returns true when the entry was added.
  bool addEntry(PokemonIndexEntry entry) {
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
    return true;
  }

  /// Removes the entry with [id], if present.
  void removeEntry(int id) {
    if (!state.isSelected(id)) return;
    _logger.info('Removing comparison entry ID: $id', prefix: _prefix);
    emit(
      state.copyWith(
        entries: state.entries.where((entry) => entry.id != id).toList(),
      ),
    );
  }

  /// Toggles [entry]; returns true when it ends up selected.
  bool toggleEntry(PokemonIndexEntry entry) {
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
    emit(state.copyWith(entries: const []));
  }
}
