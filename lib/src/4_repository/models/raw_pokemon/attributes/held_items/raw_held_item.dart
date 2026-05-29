import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/named_api_resource.dart';

part 'raw_held_item.g.dart';

@JsonSerializable()
class RawHeldItem {
  const RawHeldItem({
    required this.item,
    required this.versionDetails,
  });

  final NamedAPIResource item;

  @JsonKey(name: 'version_details')
  final List<RawHeldItemVersionDetail> versionDetails;

  factory RawHeldItem.fromJson(Map<String, dynamic> json) =>
      _$RawHeldItemFromJson(json);

  Map<String, dynamic> toJson() => _$RawHeldItemToJson(this);
}

@JsonSerializable()
class RawHeldItemVersionDetail {
  const RawHeldItemVersionDetail({
    required this.rarity,
    required this.version,
  });

  final int rarity;
  final NamedAPIResource version;

  factory RawHeldItemVersionDetail.fromJson(Map<String, dynamic> json) =>
      _$RawHeldItemVersionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawHeldItemVersionDetailToJson(this);
}
