import 'package:en_logger/en_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_ability_detail_usecase.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_state.dart';

@injectable
class AbilityDetailCubit extends Cubit<AbilityDetailState> {
  AbilityDetailCubit(this._getAbilityDetailUseCase, this._logger)
    : super(const AbilityDetailInitial());

  final GetAbilityDetailUseCase _getAbilityDetailUseCase;
  final EnLogger _logger;
  CancellationToken? _cancelToken;

  @override
  Future<void> close() {
    _cancelToken?.cancel('AbilityDetailCubit closed');
    return super.close();
  }

  Future<void> fetchAbilityDetail(String name) async {
    if (name.isEmpty) return;

    _cancelToken?.cancel('Superseded by new fetchAbilityDetail');
    final token = CancellationToken();
    _cancelToken = token;

    emit(const AbilityDetailLoading());
    _logger.info('Fetching ability detail for $name');

    final result = await _getAbilityDetailUseCase(name, cancelToken: token);

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        _logger.error('Failed to fetch ability detail: ${failure.message}');
        emit(AbilityDetailError(failure.message, failure: failure));
      },
      (abilityDetail) {
        emit(AbilityDetailLoaded(abilityDetail));
      },
    );
  }
}
