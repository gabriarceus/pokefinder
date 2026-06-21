// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_move_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawMoveDetail _$RawMoveDetailFromJson(Map<String, dynamic> json) =>
    RawMoveDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      accuracy: (json['accuracy'] as num?)?.toInt(),
      power: (json['power'] as num?)?.toInt(),
      pp: (json['pp'] as num?)?.toInt(),
      type: NamedAPIResource.fromJson(json['type'] as Map<String, dynamic>),
      damageClass: NamedAPIResource.fromJson(
          json['damage_class'] as Map<String, dynamic>),
      flavorTextEntries: (json['flavor_text_entries'] as List<dynamic>?)
              ?.map(
                  (e) => RawFlavorTextEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RawMoveDetailToJson(RawMoveDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'accuracy': instance.accuracy,
      'power': instance.power,
      'pp': instance.pp,
      'type': instance.type.toJson(),
      'damage_class': instance.damageClass.toJson(),
      'flavor_text_entries':
          instance.flavorTextEntries.map((e) => e.toJson()).toList(),
    };

RawFlavorTextEntry _$RawFlavorTextEntryFromJson(Map<String, dynamic> json) =>
    RawFlavorTextEntry(
      flavorText: json['flavor_text'] as String,
      language:
          NamedAPIResource.fromJson(json['language'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RawFlavorTextEntryToJson(RawFlavorTextEntry instance) =>
    <String, dynamic>{
      'flavor_text': instance.flavorText,
      'language': instance.language.toJson(),
    };
