import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/named_api_resource.dart';

part 'raw_game_index.g.dart';

@JsonSerializable()
class RawGameIndex {
  const RawGameIndex({
    required this.gameIndex,
    required this.version,
  });

  @JsonKey(name: 'game_index')
  final int gameIndex;

  final NamedAPIResource version;

  factory RawGameIndex.fromJson(Map<String, dynamic> json) =>
      _$RawGameIndexFromJson(json);

  Map<String, dynamic> toJson() => _$RawGameIndexToJson(this);
}
