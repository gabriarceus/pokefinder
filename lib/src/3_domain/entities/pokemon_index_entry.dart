import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_regional_group.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/helpers/pokemon_form_classifier.dart';

/// Represents a lightweight entry in the Pokémon index catalog.
class PokemonIndexEntry extends Equatable {
  const PokemonIndexEntry({
    required this.id,
    required this.name,
    required this.detailUrl,
    this.types = const [],
    this.customSpriteUrl,
    this.parentSpeciesId,
    this.parentSpeciesName,
    this.formCategory = PokemonFormCategory.canonical,
    this.regionalGroup,
    this.hasAlternateForms = false,
    this.availableFormCategories = const [],
    this.customDisplayName,
    this.introductionGeneration,
    this.speciesGeneration,
  });

  /// Canonical numeric Pokédex identifier.
  final int id;

  /// Canonical lowercase name slug (e.g. "pikachu").
  final String name;

  /// Canonical resource URL for full Pokémon details.
  final String detailUrl;

  /// Known elemental types for this Pokémon, or empty when not yet enriched.
  final List<PokemonType> types;

  /// Custom sprite URL override, if any.
  final String? customSpriteUrl;

  /// Canonical parent species ID for this entry, or [id] if canonical.
  final int? parentSpeciesId;

  /// Canonical parent species name slug, or [name] if canonical.
  final String? parentSpeciesName;

  /// Structural form classification category.
  final PokemonFormCategory formCategory;

  /// Regional group (alola, galar, hisui, paldea) if a regional form.
  final PokemonRegionalGroup? regionalGroup;

  /// Whether this canonical species possesses alternate forms in the catalog.
  final bool hasAlternateForms;

  /// List of form categories available for this canonical species.
  final List<PokemonFormCategory> availableFormCategories;

  /// Custom override for display title formatting.
  final String? customDisplayName;

  /// Franchise generation when this form or species debuted.
  final int? introductionGeneration;

  /// Generation of the base/parent species.
  final int? speciesGeneration;

  /// Canonical parent species ID. Defaults to [id] when not explicitly set.
  int get effectiveParentSpeciesId => parentSpeciesId ?? id;

  /// Canonical parent species name slug. Defaults to [name] when not explicitly set.
  String get effectiveParentSpeciesName => parentSpeciesName ?? name;

  /// Whether this entry represents an alternate battle form or variant.
  bool get isAlternateForm =>
      id > 1025 || formCategory != PokemonFormCategory.canonical;

  /// Formatted Pokédex number of the canonical parent species (e.g. "#0006").
  String get dexNumberDisplay =>
      '#${effectiveParentSpeciesId.toString().padLeft(4, '0')}';

  /// Standard pixel front-default sprite URL derived from [id].
  String get spriteUrl =>
      customSpriteUrl ??
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  /// High-resolution official artwork URL derived from [id].
  String get officialArtworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  /// Formats the [id] with a leading '#' and minimum 3 digits (e.g. "#025").
  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  /// Resolves the Pokémon generation (1-9) based on canonical Pokédex ID ranges,
  /// or 0 for alternate forms outside standard generation bounds.
  int get generation => PokemonFormClassifier.resolveGeneration(id);

  /// Effective generation of the parent species.
  int get effectiveSpeciesGeneration =>
      speciesGeneration ??
      PokemonFormClassifier.resolveGeneration(effectiveParentSpeciesId);

  /// Effective franchise introduction generation when the form debuted.
  int get effectiveIntroductionGeneration =>
      introductionGeneration ??
      (isAlternateForm
          ? PokemonFormClassifier.resolveIntroductionGeneration(
              name: name,
              category: formCategory,
              regionalGroup: regionalGroup,
              parentSpeciesId: effectiveParentSpeciesId,
            )
          : effectiveSpeciesGeneration);

  /// Formatted English display name.
  String get displayName =>
      customDisplayName ??
      PokemonFormClassifier.formatDisplayName(
        name: name,
        parentSpeciesName: effectiveParentSpeciesName,
        category: formCategory,
        regionalGroup: regionalGroup,
        languageCode: 'en',
      );

  /// Returns localized display name for [languageCode].
  String getDisplayName({String languageCode = 'en'}) =>
      customDisplayName ??
      PokemonFormClassifier.formatDisplayName(
        name: name,
        parentSpeciesName: effectiveParentSpeciesName,
        category: formCategory,
        regionalGroup: regionalGroup,
        languageCode: languageCode,
      );

  /// Label for form badge pill tag, if any.
  String? get formBadgeText {
    return switch (formCategory) {
      PokemonFormCategory.mega =>
        name.endsWith('-mega-x')
            ? 'MEGA X'
            : name.endsWith('-mega-y')
            ? 'MEGA Y'
            : 'MEGA',
      PokemonFormCategory.primal => 'PRIMAL',
      PokemonFormCategory.regional =>
        regionalGroup?.name.toUpperCase() ?? 'REGIONAL',
      PokemonFormCategory.gmax => 'G-MAX',
      PokemonFormCategory.battleMode => _resolveBattleBadge(name),
      PokemonFormCategory.cosmetic => 'SPECIAL',
      PokemonFormCategory.canonical => null,
    };
  }

  static String _resolveBattleBadge(String name) {
    final lastDash = name.lastIndexOf('-');
    if (lastDash != -1 && lastDash < name.length - 1) {
      return name.substring(lastDash + 1).toUpperCase();
    }
    return 'FORM';
  }

  PokemonIndexEntry copyWith({
    int? id,
    String? name,
    String? detailUrl,
    List<PokemonType>? types,
    String? customSpriteUrl,
    int? parentSpeciesId,
    String? parentSpeciesName,
    PokemonFormCategory? formCategory,
    PokemonRegionalGroup? regionalGroup,
    bool? hasAlternateForms,
    List<PokemonFormCategory>? availableFormCategories,
    String? customDisplayName,
    int? introductionGeneration,
    int? speciesGeneration,
  }) {
    return PokemonIndexEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      detailUrl: detailUrl ?? this.detailUrl,
      types: types ?? this.types,
      customSpriteUrl: customSpriteUrl ?? this.customSpriteUrl,
      parentSpeciesId: parentSpeciesId ?? this.parentSpeciesId,
      parentSpeciesName: parentSpeciesName ?? this.parentSpeciesName,
      formCategory: formCategory ?? this.formCategory,
      regionalGroup: regionalGroup ?? this.regionalGroup,
      hasAlternateForms: hasAlternateForms ?? this.hasAlternateForms,
      availableFormCategories:
          availableFormCategories ?? this.availableFormCategories,
      customDisplayName: customDisplayName ?? this.customDisplayName,
      introductionGeneration:
          introductionGeneration ?? this.introductionGeneration,
      speciesGeneration: speciesGeneration ?? this.speciesGeneration,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    detailUrl,
    types,
    customSpriteUrl,
    effectiveParentSpeciesId,
    effectiveParentSpeciesName,
    formCategory,
    regionalGroup,
    hasAlternateForms,
    availableFormCategories,
    customDisplayName,
    effectiveIntroductionGeneration,
    effectiveSpeciesGeneration,
  ];
}
