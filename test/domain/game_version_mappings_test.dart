import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/game_version_mappings.dart';

void main() {
  group('GameVersionMappings', () {
    test('maps version to corresponding version group', () {
      expect(GameVersionMappings.versionGroupFor('red'), 'red-blue');
      expect(GameVersionMappings.versionGroupFor('blue'), 'red-blue');
      expect(GameVersionMappings.versionGroupFor('sword'), 'sword-shield');
      expect(GameVersionMappings.versionGroupFor('scarlet'), 'scarlet-violet');
      expect(
        GameVersionMappings.versionGroupFor('unknown-version'),
        'unknown-version',
      );
    });

    test('returns versions for a given version group', () {
      expect(GameVersionMappings.versionsForGroup('red-blue'), ['red', 'blue']);
      expect(GameVersionMappings.versionsForGroup('sword-shield'), [
        'sword',
        'shield',
        'the-isle-of-armor',
        'the-crown-tundra',
      ]);
    });

    test('matches move version group to selected version', () {
      expect(
        GameVersionMappings.moveMatchesVersion(
          moveVersionGroup: 'red-blue',
          selectedVersion: 'red',
        ),
        isTrue,
      );
      expect(
        GameVersionMappings.moveMatchesVersion(
          moveVersionGroup: 'red-blue',
          selectedVersion: 'blue',
        ),
        isTrue,
      );
      expect(
        GameVersionMappings.moveMatchesVersion(
          moveVersionGroup: 'sword-shield',
          selectedVersion: 'red',
        ),
        isFalse,
      );
      expect(
        GameVersionMappings.moveMatchesVersion(
          moveVersionGroup: 'sword-shield',
          selectedVersion: 'all',
        ),
        isTrue,
      );
    });
  });
}
