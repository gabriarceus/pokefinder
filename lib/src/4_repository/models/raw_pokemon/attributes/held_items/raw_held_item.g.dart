// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_held_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawHeldItem _$RawHeldItemFromJson(Map<String, dynamic> json) => RawHeldItem(
      item: NamedAPIResource.fromJson(json['item'] as Map<String, dynamic>),
      versionDetails: (json['version_details'] as List<dynamic>)
          .map((e) =>
              RawHeldItemVersionDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RawHeldItemToJson(RawHeldItem instance) =>
    <String, dynamic>{
      'item': instance.item,
      'version_details': instance.versionDetails,
    };

RawHeldItemVersionDetail _$RawHeldItemVersionDetailFromJson(
        Map<String, dynamic> json) =>
    RawHeldItemVersionDetail(
      rarity: (json['rarity'] as num).toInt(),
      version:
          NamedAPIResource.fromJson(json['version'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RawHeldItemVersionDetailToJson(
        RawHeldItemVersionDetail instance) =>
    <String, dynamic>{
      'rarity': instance.rarity,
      'version': instance.version,
    };
