// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatContainer _$StatContainerFromJson(Map<String, dynamic> json) =>
    StatContainer(
      baseStat: (json['base_stat'] as num).toInt(),
      effort: (json['effort'] as num).toInt(),
      stat: Stat.fromJson(json['stat'] as Map<String, dynamic>),
    );
