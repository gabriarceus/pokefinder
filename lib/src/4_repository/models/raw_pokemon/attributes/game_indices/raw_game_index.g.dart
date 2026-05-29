// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_game_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawGameIndex _$RawGameIndexFromJson(Map<String, dynamic> json) => RawGameIndex(
      gameIndex: (json['game_index'] as num).toInt(),
      version:
          NamedAPIResource.fromJson(json['version'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RawGameIndexToJson(RawGameIndex instance) =>
    <String, dynamic>{
      'game_index': instance.gameIndex,
      'version': instance.version,
    };
