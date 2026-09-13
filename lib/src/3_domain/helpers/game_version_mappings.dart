/// Maps between individual game versions and PokeAPI version groups.
class GameVersionMappings {
  const GameVersionMappings._();

  static const Map<String, List<String>> _groupToVersions = {
    'red-blue': ['red', 'blue'],
    'yellow': ['yellow'],
    'gold-silver': ['gold', 'silver'],
    'crystal': ['crystal'],
    'ruby-sapphire': ['ruby', 'sapphire'],
    'emerald': ['emerald'],
    'firered-leafgreen': ['firered', 'leafgreen'],
    'diamond-pearl': ['diamond', 'pearl'],
    'platinum': ['platinum'],
    'heartgold-soulsilver': ['heartgold', 'soulsilver'],
    'black-white': ['black', 'white'],
    'black-2-white-2': ['black-2', 'white-2'],
    'x-y': ['x', 'y'],
    'omega-ruby-alpha-sapphire': ['omega-ruby', 'alpha-sapphire'],
    'sun-moon': ['sun', 'moon'],
    'ultra-sun-ultra-moon': ['ultra-sun', 'ultra-moon'],
    'lets-go-pikachu-lets-go-eevee': ['lets-go-pikachu', 'lets-go-eevee'],
    'sword-shield': [
      'sword',
      'shield',
      'the-isle-of-armor',
      'the-crown-tundra',
    ],
    'brilliant-diamond-and-shining-pearl': [
      'brilliant-diamond',
      'shining-pearl',
    ],
    'legends-arceus': ['legends-arceus'],
    'scarlet-violet': ['scarlet', 'violet', 'the-teal-mask', 'the-indigo-disk'],
    'colosseum': ['colosseum'],
    'xd': ['xd'],
  };

  static final Map<String, String> _versionToGroup = () {
    final map = <String, String>{};
    for (final entry in _groupToVersions.entries) {
      for (final v in entry.value) {
        map[v] = entry.key;
      }
    }
    return map;
  }();

  /// Canonical chronological list of game versions across generations.
  static final List<String> canonicalVersions = [
    for (final versions in _groupToVersions.values) ...versions,
  ];

  /// Sorts [versions] in-place according to chronological franchise release order,
  /// with unrecognized versions sorted alphabetically at the end.
  static void sortVersions(List<String> versions) {
    versions.sort((a, b) {
      final indexA = canonicalVersions.indexOf(a.toLowerCase());
      final indexB = canonicalVersions.indexOf(b.toLowerCase());
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      if (indexA != -1) return -1;
      if (indexB != -1) return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
  }

  /// Resolves the version group for a specific [version].
  /// Returns [version] itself if no explicit mapping is known.
  static String versionGroupFor(String version) =>
      _versionToGroup[version.toLowerCase()] ?? version;

  /// Returns the list of versions contained within [versionGroup].
  static List<String> versionsForGroup(String versionGroup) =>
      _groupToVersions[versionGroup.toLowerCase()] ?? [versionGroup];

  /// Checks whether a move's [moveVersionGroup] matches the [selectedVersion].
  /// When [selectedVersion] is 'all', always returns true.
  static bool moveMatchesVersion({
    required String moveVersionGroup,
    required String selectedVersion,
  }) {
    if (selectedVersion.isEmpty || selectedVersion == 'all') return true;

    final targetGroup = versionGroupFor(selectedVersion);
    if (moveVersionGroup.toLowerCase() == targetGroup.toLowerCase()) {
      return true;
    }
    return moveVersionGroup.toLowerCase() == selectedVersion.toLowerCase();
  }
}
