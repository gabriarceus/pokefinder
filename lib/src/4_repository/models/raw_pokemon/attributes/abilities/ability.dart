import 'package:json_annotation/json_annotation.dart';
part 'ability.g.dart';

@JsonSerializable()
class Ability {
  const Ability({
    required this.name,
  });

  final String name;

  factory Ability.fromJson(Map<String, dynamic> json) =>
      _$AbilityFromJson(json);

  Map<String, dynamic> toJson() => _$AbilityToJson(this);
}
