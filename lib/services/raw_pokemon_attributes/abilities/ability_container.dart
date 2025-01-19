import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/services/raw_pokemon_attributes/abilities/ability.dart';

part 'ability_container.g.dart';

@JsonSerializable()
class AbilityContainer {
  const AbilityContainer({
    required this.ability,
  });

  final Ability ability;

  factory AbilityContainer.fromJson(Map<String, dynamic> json) => _$AbilityContainerFromJson(json);

  Map<String, dynamic> toJson() => _$AbilityContainerToJson(this);
}