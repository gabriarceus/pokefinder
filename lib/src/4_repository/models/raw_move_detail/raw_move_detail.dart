import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/attributes.dart';

part 'raw_move_detail.g.dart';

@JsonSerializable(explicitToJson: true)
class RawMoveDetail {
  const RawMoveDetail({
    required this.id,
    required this.name,
    this.accuracy,
    this.power,
    this.pp,
    required this.type,
    required this.damageClass,
    this.flavorTextEntries = const [],
  });

  final int id;
  final String name;
  final int? accuracy;
  final int? power;
  final int? pp;
  final NamedAPIResource type;
  @JsonKey(name: 'damage_class')
  final NamedAPIResource damageClass;
  @JsonKey(name: 'flavor_text_entries')
  final List<RawFlavorTextEntry> flavorTextEntries;

  factory RawMoveDetail.fromJson(Map<String, dynamic> json) =>
      _$RawMoveDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawMoveDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RawFlavorTextEntry {
  const RawFlavorTextEntry({
    required this.flavorText,
    required this.language,
  });

  @JsonKey(name: 'flavor_text')
  final String flavorText;
  final NamedAPIResource language;

  factory RawFlavorTextEntry.fromJson(Map<String, dynamic> json) =>
      _$RawFlavorTextEntryFromJson(json);

  Map<String, dynamic> toJson() => _$RawFlavorTextEntryToJson(this);
}
