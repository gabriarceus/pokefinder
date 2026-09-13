import 'package:equatable/equatable.dart';

/// Domain entity representing detailed information about a Pokémon ability.
class AbilityDetail extends Equatable {
  const AbilityDetail({
    required this.id,
    required this.name,
    this.flavorTexts = const {},
    this.effects = const {},
    this.shortEffects = const {},
  });

  final int id;
  final String name;
  final Map<String, String> flavorTexts;
  final Map<String, String> effects;
  final Map<String, String> shortEffects;

  /// Returns the short effect or flavor text for [languageCode], with English fallback.
  String descriptionFor(String? languageCode) {
    final lang = languageCode ?? 'en';
    if (shortEffects.containsKey(lang) && shortEffects[lang]!.isNotEmpty) {
      return shortEffects[lang]!;
    }
    if (flavorTexts.containsKey(lang) && flavorTexts[lang]!.isNotEmpty) {
      return flavorTexts[lang]!;
    }
    return shortEffects['en'] ?? flavorTexts['en'] ?? '';
  }

  /// Returns the detailed in-battle effect for [languageCode], with English fallback.
  String effectFor(String? languageCode) {
    final lang = languageCode ?? 'en';
    if (effects.containsKey(lang) && effects[lang]!.isNotEmpty) {
      return effects[lang]!;
    }
    return effects['en'] ?? descriptionFor(lang);
  }

  @override
  List<Object?> get props => [id, name, flavorTexts, effects, shortEffects];
}
