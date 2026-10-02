import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_moves_cubit.dart';
import 'package:pokefinder/src/2_application/helpers/move_name_resolver.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';

class MockEnLogger extends Mock implements EnLogger {}

/// Turns a PokeAPI move slug into its English display name, the same way the
/// real resolver (fed by the moves database) does.
String _displayName(String slug) => slug
    .split('-')
    .map(
      (part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');

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
  const moveName = MoveNameResolver(_displayName);

  group('DetailMovesCubit', () {
    test('initial state derives methods and defaults to the latest group', () {
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: moveName,
        logger: logger,
      );
      final state = cubit.state;

      // 'platinum' is the most recent version group of these moves, so it is
      // the initial selection.
      expect(state.selectedVersionGroup, 'platinum');
      expect(state.selectedMethod, DetailMovesCubit.allMethodsFilter);
      expect(state.availableMethods, [
        DetailMovesCubit.allMethodsFilter,
        'egg',
      ]);
      // Filtered to the selected version group's moves.
      expect(state.filteredMoves.map((m) => m.name), containsAll(['wish']));
      expect(state.filteredMoves.map((m) => m.name), isNot(contains('cut')));

      cubit.close();
    });

    test('selecting an explicit game version recomputes methods and moves', () {
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: moveName,
        logger: logger,
      );

      cubit.selectGameVersion('diamond');

      expect(cubit.state.selectedVersionGroup, 'diamond-pearl');
      expect(cubit.state.availableMethods, [
        DetailMovesCubit.allMethodsFilter,
        'level-up',
        'machine',
      ]);
      expect(cubit.state.filteredMoves.map((m) => m.name), [
        'tackle',
        'growl',
        'cut',
      ]);

      cubit.close();
    });

    test('a game version with no moves empties the list', () {
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: moveName,
        logger: logger,
      );

      // 'red' belongs to the 'red-blue' group, which none of these moves use.
      cubit.selectGameVersion('red');

      expect(cubit.state.selectedVersionGroup, 'red-blue');
      expect(cubit.state.filteredMoves, isEmpty);
      expect(cubit.state.availableMethods, [DetailMovesCubit.allMethodsFilter]);

      cubit.close();
    });

    test('selected method resets to "all" when unavailable in new group', () {
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: moveName,
        logger: logger,
      );

      cubit.selectGameVersion('diamond-pearl');
      cubit.updateSelectedMethod('machine');
      expect(cubit.state.selectedMethod, 'machine');
      expect(cubit.state.filteredMoves.map((m) => m.name), ['cut']);

      // 'platinum' has no 'machine' moves, so the filter falls back to "all".
      cubit.selectGameVersion('platinum');
      expect(cubit.state.selectedMethod, DetailMovesCubit.allMethodsFilter);
      expect(cubit.state.filteredMoves.map((m) => m.name), ['wish']);

      cubit.close();
    });

    test('search query filters by move slug', () {
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: moveName,
        logger: logger,
      );

      cubit.selectGameVersion('diamond-pearl');
      cubit.updateSearchQuery('grow');
      expect(cubit.state.filteredMoves.map((m) => m.name), ['growl']);

      cubit.close();
    });

    test('search query also matches the resolved display name', () {
      const labelledResolver = MoveNameResolver(_labelledDisplayName);
      final cubit = DetailMovesCubit(
        moves: moves,
        moveName: labelledResolver,
        logger: logger,
      );

      cubit.selectGameVersion('diamond-pearl');
      // 'Move: cut' is only reachable through the resolved display name; the
      // slug 'cut' does not contain it.
      cubit.updateSearchQuery('Move: cut');
      expect(cubit.state.filteredMoves.map((m) => m.name), ['cut']);

      cubit.close();
    });
  });

  group('DetailMovesCubit sorting', () {
    // Deliberately unsorted, and mixing every learn method plus a
    // same-level tie inside 'level-up'.
    const mixedMoves = [
      PokemonMove(
        name: 'vine-whip',
        levelLearnedAt: 1,
        learnMethod: 'level-up',
        versionGroup: 'diamond-pearl',
      ),
      PokemonMove(
        name: 'wish',
        levelLearnedAt: 0,
        learnMethod: 'egg',
        versionGroup: 'diamond-pearl',
      ),
      PokemonMove(
        name: 'razor-leaf',
        levelLearnedAt: 7,
        learnMethod: 'level-up',
        versionGroup: 'diamond-pearl',
      ),
      PokemonMove(
        name: 'flash',
        levelLearnedAt: 0,
        learnMethod: 'tutor',
        versionGroup: 'diamond-pearl',
      ),
      PokemonMove(
        name: 'tackle',
        levelLearnedAt: 1,
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
        name: 'growl',
        levelLearnedAt: 3,
        learnMethod: 'level-up',
        versionGroup: 'diamond-pearl',
      ),
      PokemonMove(
        name: 'sleep-powder',
        levelLearnedAt: 0,
        learnMethod: 'stadium',
        versionGroup: 'diamond-pearl',
      ),
    ];

    test('orders by method group, then level, then display name', () {
      final cubit = DetailMovesCubit(
        moves: mixedMoves,
        moveName: moveName,
        logger: logger,
      );

      // 'level-up' first (by level, 'Tackle' before 'Vine Whip' at level 1),
      // then machine, tutor, egg, and finally the unrecognized method.
      expect(cubit.state.filteredMoves.map((m) => m.name), [
        'tackle',
        'vine-whip',
        'growl',
        'razor-leaf',
        'cut',
        'flash',
        'wish',
        'sleep-powder',
      ]);

      cubit.close();
    });

    test('the order does not depend on the input order', () {
      List<String> orderOf(List<PokemonMove> moves) {
        final cubit = DetailMovesCubit(
          moves: moves,
          moveName: moveName,
          logger: logger,
        );
        final names = cubit.state.filteredMoves.map((m) => m.name).toList();
        cubit.close();
        return names;
      }

      expect(orderOf(mixedMoves.reversed.toList()), orderOf(mixedMoves));
    });

    test('ties on level are broken by display name, not by slug', () {
      const tiedMoves = [
        PokemonMove(
          name: 'zz-top',
          levelLearnedAt: 1,
          learnMethod: 'level-up',
          versionGroup: 'diamond-pearl',
        ),
        PokemonMove(
          name: 'aa-bottom',
          levelLearnedAt: 1,
          learnMethod: 'level-up',
          versionGroup: 'diamond-pearl',
        ),
      ];

      const renamingResolver = MoveNameResolver(_swapDisplayNames);
      final cubit = DetailMovesCubit(
        moves: tiedMoves,
        moveName: renamingResolver,
        logger: logger,
      );

      // Slug order would put 'aa-bottom' first; the display names invert it.
      expect(cubit.state.filteredMoves.map((m) => m.name), [
        'zz-top',
        'aa-bottom',
      ]);

      cubit.close();
    });
  });
}

/// Renames two slugs so that display-name order is the reverse of slug order.
String _swapDisplayNames(String slug) => switch (slug) {
  'zz-top' => 'Aardvark',
  'aa-bottom' => 'Zebra',
  _ => slug,
};

/// A display name that shares no substring with the slug it is resolved from.
String _labelledDisplayName(String slug) => 'Move: $slug';
