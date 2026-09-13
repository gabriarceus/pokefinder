import 'package:equatable/equatable.dart';

/// Flavor text entry tied to a language and game version.
class PokemonSpeciesFlavorText extends Equatable {
  const PokemonSpeciesFlavorText({
    required this.text,
    required this.language,
    required this.version,
  });

  final String text;
  final String language;
  final String version;

  @override
  List<Object?> get props => [text, language, version];
}

/// Domain entity representing detailed species metadata for a Pokémon.
class PokemonSpecies extends Equatable {
  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.flavorTexts,
    required this.genera,
    this.generation,
    this.habitat,
    this.captureRate,
    this.baseHappiness,
    this.growthRate,
    this.genderRate,
    this.eggGroups = const [],
    this.evolutionChainUrl,
    this.isBaby = false,
    this.isLegendary = false,
    this.isMythical = false,
  });

  final int id;
  final String name;
  final List<PokemonSpeciesFlavorText> flavorTexts;
  final Map<String, String> genera;
  final String? generation;
  final String? habitat;
  final int? captureRate;
  final int? baseHappiness;
  final String? growthRate;
  final int? genderRate;
  final List<String> eggGroups;
  final String? evolutionChainUrl;
  final bool isBaby;
  final bool isLegendary;
  final bool isMythical;

  /// Resolves the most appropriate genus description for [languageCode],
  /// falling back to English when unavailable.
  String genusFor(String? languageCode) {
    if (languageCode != null && genera.containsKey(languageCode)) {
      return genera[languageCode]!;
    }
    return genera['en'] ?? '';
  }

  /// Resolves the most appropriate Pokédex flavor text for [languageCode] and [version],
  /// prioritizing active language and matching version with fallback to English.
  String flavorTextFor({String? languageCode, String? version}) {
    if (flavorTexts.isEmpty) return '';

    final lang = languageCode ?? 'en';

    if (version != null && version.isNotEmpty && version != 'all') {
      // 1. Target language + target version
      final exactMatch = flavorTexts.firstWhere(
        (f) => f.language == lang && f.version == version,
        orElse: () =>
            const PokemonSpeciesFlavorText(text: '', language: '', version: ''),
      );
      if (exactMatch.text.isNotEmpty) return exactMatch.text;

      // 2. English + target version
      if (lang != 'en') {
        final enVersionMatch = flavorTexts.firstWhere(
          (f) => f.language == 'en' && f.version == version,
          orElse: () => const PokemonSpeciesFlavorText(
            text: '',
            language: '',
            version: '',
          ),
        );
        if (enVersionMatch.text.isNotEmpty) return enVersionMatch.text;
      }
    }

    // 3. Target language + any version (prefer most recent entry)
    final langMatch = flavorTexts.lastWhere(
      (f) => f.language == lang,
      orElse: () =>
          const PokemonSpeciesFlavorText(text: '', language: '', version: ''),
    );
    if (langMatch.text.isNotEmpty) return langMatch.text;

    // 4. English + any version (prefer most recent entry)
    final enMatch = flavorTexts.lastWhere(
      (f) => f.language == 'en',
      orElse: () =>
          const PokemonSpeciesFlavorText(text: '', language: '', version: ''),
    );
    return enMatch.text;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    flavorTexts,
    genera,
    generation,
    habitat,
    captureRate,
    baseHappiness,
    growthRate,
    genderRate,
    eggGroups,
    evolutionChainUrl,
    isBaby,
    isLegendary,
    isMythical,
  ];
}
