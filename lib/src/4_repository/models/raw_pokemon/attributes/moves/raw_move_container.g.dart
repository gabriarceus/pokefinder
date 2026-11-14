// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_move_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawMoveContainer _$RawMoveContainerFromJson(Map<String, dynamic> json) =>
    RawMoveContainer(
      move: NamedAPIResource.fromJson(json['move'] as Map<String, dynamic>),
      versionGroupDetails: (json['version_group_details'] as List<dynamic>)
          .map(
            (e) =>
                RawMoveVersionGroupDetail.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

RawMoveVersionGroupDetail _$RawMoveVersionGroupDetailFromJson(
  Map<String, dynamic> json,
) => RawMoveVersionGroupDetail(
  levelLearnedAt: (json['level_learned_at'] as num).toInt(),
  moveLearnMethod: NamedAPIResource.fromJson(
    json['move_learn_method'] as Map<String, dynamic>,
  ),
  versionGroup: NamedAPIResource.fromJson(
    json['version_group'] as Map<String, dynamic>,
  ),
);
