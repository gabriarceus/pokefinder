import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_moves_cubit.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';

class MockEnLogger extends Mock implements EnLogger {}

void main() {
  const moves = [
    PokemonMove(
      name: 'tackle',
      levelLearnedAt: 1,
      learnMethod: 'level-up',
      versionGroup: 'diamond-pearl',
    ),
    PokemonMove(
      name: 'growl',
      levelLearnedAt: 3,
      learnMethod: 'level-up',
      versionGroup: 'diamond-pearl',
    ),
    PokemonMove(
      name: 'cut',
      levelLearnedAt: 0,
      learnMethod: 'machine',
      versionGroup: 'diamond-pearl',
    ),
    PokemonMove(
      name: 'wish',
      levelLearnedAt: 0,
      learnMethod: 'egg',
      versionGroup: 'platinum',
    ),
  ];

  final logger = MockEnLogger();

  group('DetailMovesCubit', () {
    test('initial state derives version groups, methods and default group', () {
      final cubit = DetailMovesCubit(moves: moves, logger: logger);
      final state = cubit.state;

      expect(state.versionGroups, containsAll(['diamond-pearl', 'platinum']));
      // 'diamond-pearl' is preferred as the initial selection.
      expect(state.selectedVersionGroup, 'diamond-pearl');
      expect(state.selectedMethod, DetailMovesCubit.allMethodsFilter);
      expect(state.availableMethods, [
        DetailMovesCubit.allMethodsFilter,
        'level-up',
        'machine',
      ]);
      // Filtered to the selected version group's moves.
      expect(
        state.filteredMoves.map((m) => m.name),
        containsAll(['tackle', 'growl', 'cut']),
      );

      cubit.close();
    });

    test('changing version group recomputes methods and filtered moves', () {
      final cubit = DetailMovesCubit(moves: moves, logger: logger);

      cubit.updateSelectedVersionGroup('platinum', 'en');

      expect(cubit.state.selectedVersionGroup, 'platinum');
      expect(cubit.state.availableMethods,
          [DetailMovesCubit.allMethodsFilter, 'egg']);
      expect(cubit.state.filteredMoves.map((m) => m.name), ['wish']);

      cubit.close();
    });

    test('selected method resets to "all" when unavailable in new group', () {
      final cubit = DetailMovesCubit(moves: moves, logger: logger);

      cubit.updateSelectedMethod('machine', 'en');
      expect(cubit.state.selectedMethod, 'machine');

      // 'platinum' has no 'machine' moves, so the filter falls back to "all".
      cubit.updateSelectedVersionGroup('platinum', 'en');
      expect(cubit.state.selectedMethod, DetailMovesCubit.allMethodsFilter);

      cubit.close();
    });

    test('search query filters by move name', () {
      final cubit = DetailMovesCubit(moves: moves, logger: logger);

      cubit.updateSearchQuery('grow', 'en');
      expect(cubit.state.filteredMoves.map((m) => m.name), ['growl']);

      cubit.close();
    });
  });
}
