import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/2_application/bloc/load_cubit/load_state.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

/// Runs [_loader] and exposes its result as a [LoadState]. [load] also retries.
class LoadCubit<T> extends Cubit<LoadState<T>> {
  LoadCubit(this._loader, this._logger) : super(LoadInProgress<T>());

  static const _prefix = 'LoadCubit';

  final Future<Either<PokemonFailure, T>> Function() _loader;
  final EnLogger _logger;

  Future<void> load() async {
    emit(LoadInProgress<T>());
    final result = await _loader();
    if (isClosed) return;

    result.fold((failure) {
      _logger.error('Failed to load $T: ${failure.message}', prefix: _prefix);
      emit(LoadFailure(failure));
    }, (value) => emit(LoadSuccess(value)));
  }
}
