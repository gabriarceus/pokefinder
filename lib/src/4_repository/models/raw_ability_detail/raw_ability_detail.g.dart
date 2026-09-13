// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_ability_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawAbilityDetail _$RawAbilityDetailFromJson(Map<String, dynamic> json) =>
    RawAbilityDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      effectEntries:
          (json['effect_entries'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RawAbilityEffectEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      flavorTextEntries:
          (json['flavor_text_entries'] as List<dynamic>?)
              ?.map(
                (e) => RawAbilityFlavorTextEntry.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RawAbilityDetailToJson(RawAbilityDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'effect_entries': instance.effectEntries.map((e) => e.toJson()).toList(),
      'flavor_text_entries': instance.flavorTextEntries
          .map((e) => e.toJson())
          .toList(),
    };

RawAbilityEffectEntry _$RawAbilityEffectEntryFromJson(
  Map<String, dynamic> json,
) => RawAbilityEffectEntry(
  effect: json['effect'] as String,
  shortEffect: json['short_effect'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RawAbilityEffectEntryToJson(
  RawAbilityEffectEntry instance,
) => <String, dynamic>{
  'effect': instance.effect,
  'short_effect': instance.shortEffect,
  'language': instance.language.toJson(),
};

RawAbilityFlavorTextEntry _$RawAbilityFlavorTextEntryFromJson(
  Map<String, dynamic> json,
) => RawAbilityFlavorTextEntry(
  flavorText: json['flavor_text'] as String,
  language: NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RawAbilityFlavorTextEntryToJson(
  RawAbilityFlavorTextEntry instance,
) => <String, dynamic>{
  'flavor_text': instance.flavorText,
  'language': instance.language.toJson(),
};
