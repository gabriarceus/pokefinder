import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_state.dart';

@injectable
class AbilityDetailCubit extends Cubit<AbilityDetailState> {
  AbilityDetailCubit(this._repository, this._logger)
    : super(const AbilityDetailInitial());

  final IPokemonRepository _repository;
  final EnLogger _logger;

  Future<void> fetchAbilityDetail(String name) async {
    if (name.isEmpty) return;

    emit(const AbilityDetailLoading());
    _logger.info('Fetching ability detail for $name');

    final result = await _repository.getAbilityDetail(name);
    if (isClosed) return;

    result.fold((failure) {
      _logger.error('Failed to fetch ability detail: ${failure.message}');
      emit(AbilityDetailError(failure.message, failure: failure));
    }, (abilityDetail) => emit(AbilityDetailLoaded(abilityDetail)));
  }
}
