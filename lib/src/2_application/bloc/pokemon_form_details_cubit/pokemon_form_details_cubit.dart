import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Loads the details of the forms that carry no types, keyed by form name.
///
/// Each result is emitted as it arrives. A failed form has no entry.
@injectable
class PokemonFormDetailsCubit extends Cubit<Map<String, PokemonFormDetails>> {
  PokemonFormDetailsCubit(this._logger, this._repository) : super(const {});

  static const _prefix = 'PokemonFormDetailsCubit';
  final EnLogger _logger;
  final IPokemonRepository _repository;

  /// Loads the details of every form of [forms] without types.
  Future<void> load(List<PokemonForm> forms) async {
    await Future.wait([
      for (final form in forms)
        if (form.type1 == null) _loadForm(form.name),
    ]);
  }

  Future<void> _loadForm(String name) async {
    final result = await _repository.getFormDetails(
      PokeApiUrlHelper.pokemonUrl(name),
    );
    if (isClosed) return;
    result.fold(
      (failure) => _logger.warning(
        'Failed to load form $name: $failure',
        prefix: _prefix,
      ),
      (details) => emit({...state, name: details}),
    );
  }
}
