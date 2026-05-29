import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/abilities/ability.dart';

part 'ability_container.g.dart';

@JsonSerializable()
class AbilityContainer {
  const AbilityContainer({
    required this.ability,
    required this.isHidden,
    required this.slot,
  });

  final Ability ability;

  @JsonKey(name: 'is_hidden')
  final bool isHidden;

  final int slot;

  factory AbilityContainer.fromJson(Map<String, dynamic> json) =>
      _$AbilityContainerFromJson(json);

  Map<String, dynamic> toJson() => _$AbilityContainerToJson(this);
}
