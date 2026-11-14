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

  /// Replaces the list with [names], keeping the entry of every name already
  /// in the list and loading only the new names.
  void load(List<String> names) {
    final previous = {
      for (var i = 0; i < _names.length; i++) _names[i]: state[i],
    };
    _names = List.unmodifiable(names);
    emit([for (final name in names) previous[name] ?? const PokemonLoading()]);
    for (final name in names.toSet()) {
      if (!previous.containsKey(name)) _load(name);
    }
  }

  /// Loads the entry at [index] again, replacing a previous failure.
  void retry(int index) {
    if (index < 0 || index >= _names.length) return;
    final name = _names[index];
    _setAll(name, const PokemonLoading());
    _load(name);
  }

  Future<void> _load(String name) async {
    final result = await _repository.getPokemon(PokemonName(name));
    if (isClosed) return;
    result.fold((failure) {
      _logger.error('Failed to load $name: $failure', prefix: _prefix);
      _setAll(name, PokemonLoadFailed(failure));
    }, (pokemon) => _setAll(name, PokemonLoaded(pokemon)));
  }

  /// Sets [load] on every entry of [name]; a name no longer listed is ignored.
  void _setAll(String name, PokemonLoad load) {
    emit([
      for (var i = 0; i < _names.length; i++)
        _names[i] == name ? load : state[i],
    ]);
  }
}
