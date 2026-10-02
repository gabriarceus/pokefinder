import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_load/pokemon_load.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Loads the details of an ordered list of Pokémon, one [PokemonLoad] per
/// name, in the same order.
///
/// A failure on one entry never affects the others.
@injectable
class PokemonListCubit extends Cubit<List<PokemonLoad>> {
  PokemonListCubit(this._logger, this._repository) : super(const []);

  static const _prefix = 'PokemonListCubit';
  final EnLogger _logger;
  final IPokemonRepository _repository;
  List<String> _names = const [];

  /// Replaces the list with [names] and loads every entry.
  void load(List<String> names) {
    _names = List.unmodifiable(names);
    emit([for (final _ in names) const PokemonLoading()]);
    for (var i = 0; i < names.length; i++) {
      _loadAt(i);
    }
  }

  /// Loads the entry at [index] again, replacing a previous failure.
  void retry(int index) {
    if (index < 0 || index >= _names.length) return;
    _setAt(index, const PokemonLoading());
    _loadAt(index);
  }

  Future<void> _loadAt(int index) async {
    final names = _names;
    final name = names[index];
    final result = await _repository.getPokemon(PokemonName(name));
    // A newer load() replaced the list meanwhile: this result is stale.
    if (isClosed || !identical(names, _names)) return;
    result.fold((failure) {
      _logger.error('Failed to load $name: $failure', prefix: _prefix);
      _setAt(index, PokemonLoadFailed(failure));
    }, (pokemon) => _setAt(index, PokemonLoaded(pokemon)));
  }

  void _setAt(int index, PokemonLoad load) {
    emit([...state]..[index] = load);
  }
}
