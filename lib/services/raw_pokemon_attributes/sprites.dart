import 'package:json_annotation/json_annotation.dart';

part 'sprites.g.dart';

@JsonSerializable()
class Sprites {
  const Sprites({
    required this.frontDefault,
  });

  @JsonKey(name: 'front_default')
  final String frontDefault;

  factory Sprites.fromJson(Map<String, dynamic> json) => _$SpritesFromJson(json);

  Map<String, dynamic> toJson() => _$SpritesToJson(this);
}