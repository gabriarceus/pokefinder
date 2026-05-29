import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/named_api_resource.dart';

part 'raw_move_container.g.dart';

@JsonSerializable()
class RawMoveContainer {
  const RawMoveContainer({
    required this.move,
    required this.versionGroupDetails,
  });

  final NamedAPIResource move;

  @JsonKey(name: 'version_group_details')
  final List<RawMoveVersionGroupDetail> versionGroupDetails;

  factory RawMoveContainer.fromJson(Map<String, dynamic> json) =>
      _$RawMoveContainerFromJson(json);

  Map<String, dynamic> toJson() => _$RawMoveContainerToJson(this);
}

@JsonSerializable()
class RawMoveVersionGroupDetail {
  const RawMoveVersionGroupDetail({
    required this.levelLearnedAt,
    required this.moveLearnMethod,
    required this.versionGroup,
  });

  @JsonKey(name: 'level_learned_at')
  final int levelLearnedAt;

  @JsonKey(name: 'move_learn_method')
  final NamedAPIResource moveLearnMethod;

  @JsonKey(name: 'version_group')
  final NamedAPIResource versionGroup;

  factory RawMoveVersionGroupDetail.fromJson(Map<String, dynamic> json) =>
      _$RawMoveVersionGroupDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawMoveVersionGroupDetailToJson(this);
}
