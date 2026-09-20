import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_cubit.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import '../fixtures/pokemon_fixture.dart';

void main() {
  group('DetailGameVersionCubit', () {
    late DetailGameVersionCubit cubit;

    setUp(() {
      cubit = DetailGameVersionCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has allVersions as selected', () {
      expect(cubit.state.selectedVersion, 'all');
      expect(cubit.state.isAllVersions, isTrue);
      expect(cubit.state.availableVersions, isEmpty);
    });

    test(
      'initialize extracts unique game versions from pokemon moves, encounters, and items',
      () {
        final pokemon = buildPokemon(
          moves: [
            const PokemonMove(
              name: 'vine-whip',
              levelLearnedAt: 7,
              learnMethod: 'level-up',
              versionGroup: 'red-blue',
            ),
          ],
        );

        final encounters = [
          const PokemonEncounter(
            locationAreaName: 'Kanto Route 1',
            rawLocationAreaName: 'kanto-route-1',
            versions: ['red', 'blue', 'yellow'],
          ),
        ];

        cubit.initialize(pokemon, encounters: encounters);

        expect(
          cubit.state.availableVersions,
          containsAll(['red', 'blue', 'yellow']),
        );
      },
    );

    test('selectVersion updates selectedVersion state', () {
      cubit.selectVersion('red');
      expect(cubit.state.selectedVersion, 'red');
      expect(cubit.state.isAllVersions, isFalse);

      cubit.selectVersion('all');
      expect(cubit.state.isAllVersions, isTrue);
    });

    test(
      're-initializing with pokemon lacking selected version resets to all',
      () {
        final gen1Pokemon = buildPokemon(
          moves: [
            const PokemonMove(
              name: 'vine-whip',
              levelLearnedAt: 7,
              learnMethod: 'level-up',
              versionGroup: 'red-blue',
            ),
          ],
        );
        cubit.initialize(gen1Pokemon);
        cubit.selectVersion('red');
        expect(cubit.state.selectedVersion, 'red');

        final gen9Pokemon = buildPokemon(
          moves: [
            const PokemonMove(
              name: 'flower-trick',
              levelLearnedAt: 1,
              learnMethod: 'level-up',
              versionGroup: 'scarlet-violet',
            ),
          ],
        );
        cubit.initialize(gen9Pokemon);
        expect(cubit.state.selectedVersion, 'all');
        expect(
          cubit.state.availableVersions,
          containsAll(['scarlet', 'violet']),
        );
        expect(cubit.state.availableVersions, isNot(contains('red')));
      },
    );

    test('sorts versions in chronological canonical franchise order', () {
      final multiGenPokemon = buildPokemon(
        gameIndices: ['sword', 'red', 'diamond', 'ruby'],
      );

      cubit.initialize(multiGenPokemon);

      expect(cubit.state.availableVersions, [
        'red',
        'ruby',
        'diamond',
        'sword',
      ]);
    });
  });
}
