import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/load_cubit/load_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/load_cubit/load_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

void main() {
  late _MockEnLogger logger;
  late LoadCubit<int> cubit;
  late Either<PokemonFailure, int> result;

  setUp(() {
    logger = _MockEnLogger();
    result = right(7);
    cubit = LoadCubit(() async => result, logger);
  });

  tearDown(() => cubit.close());

  test('starts in progress', () {
    expect(cubit.state, const LoadInProgress<int>());
  });

  test('load emits in progress then success', () async {
    final emitted = <LoadState<int>>[];
    final subscription = cubit.stream.listen(emitted.add);

    await cubit.load();
    await pumpEventQueue();
    await subscription.cancel();

    expect(emitted, [const LoadInProgress<int>(), const LoadSuccess(7)]);
  });

  test('load emits the failure and logs it', () async {
    result = left(const NetworkUnavailableFailure());

    await cubit.load();

    expect(cubit.state, const LoadFailure<int>(NetworkUnavailableFailure()));
    verify(() => logger.error(any(), prefix: any(named: 'prefix'))).called(1);
  });

  test('load after a failure recovers', () async {
    result = left(const NetworkUnavailableFailure());
    await cubit.load();
    result = right(7);

    await cubit.load();

    expect(cubit.state, const LoadSuccess(7));
  });
}
