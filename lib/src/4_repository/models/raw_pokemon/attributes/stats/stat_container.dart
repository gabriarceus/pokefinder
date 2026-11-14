import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/stats/stat.dart';

part 'stat_container.g.dart';

@JsonSerializable(createToJson: false)
class StatContainer {
  const StatContainer({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  @JsonKey(name: 'base_stat')
  final int baseStat;
  final int effort;
  final Stat stat;

  factory StatContainer.fromJson(Map<String, dynamic> json) =>
      _$StatContainerFromJson(json);
}
