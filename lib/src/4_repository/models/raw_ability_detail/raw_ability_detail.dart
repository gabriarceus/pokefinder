import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_ability_detail.g.dart';

@JsonSerializable(explicitToJson: true)
class RawAbilityDetail {
  const RawAbilityDetail({
    required this.id,
    required this.name,
    this.effectEntries = const [],
    this.flavorTextEntries = const [],
  });

  final int id;
  final String name;

  @JsonKey(name: 'effect_entries')
  final List<RawAbilityEffectEntry> effectEntries;

  @JsonKey(name: 'flavor_text_entries')
  final List<RawAbilityFlavorTextEntry> flavorTextEntries;

  factory RawAbilityDetail.fromJson(Map<String, dynamic> json) =>
      _$RawAbilityDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawAbilityDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawAbilityEffectEntry {
  const RawAbilityEffectEntry({
    required this.effect,
    required this.shortEffect,
    required this.language,
  });

  final String effect;

  @JsonKey(name: 'short_effect')
  final String shortEffect;

  final NamedAPIResource language;

  factory RawAbilityEffectEntry.fromJson(Map<String, dynamic> json) =>
      _$RawAbilityEffectEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RawAbilityEffectEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawAbilityFlavorTextEntry {
  const RawAbilityFlavorTextEntry({
    required this.flavorText,
    required this.language,
  });

  @JsonKey(name: 'flavor_text')
  final String flavorText;

  final NamedAPIResource language;

  factory RawAbilityFlavorTextEntry.fromJson(Map<String, dynamic> json) =>
      _$RawAbilityFlavorTextEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RawAbilityFlavorTextEntryToJson(this);
}
