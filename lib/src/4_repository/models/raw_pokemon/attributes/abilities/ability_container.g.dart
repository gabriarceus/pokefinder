// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ability_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbilityContainer _$AbilityContainerFromJson(Map<String, dynamic> json) =>
    AbilityContainer(
      ability: Ability.fromJson(json['ability'] as Map<String, dynamic>),
      isHidden: json['is_hidden'] as bool,
      slot: (json['slot'] as num).toInt(),
    );

Map<String, dynamic> _$AbilityContainerToJson(AbilityContainer instance) =>
    <String, dynamic>{
      'ability': instance.ability,
      'is_hidden': instance.isHidden,
      'slot': instance.slot,
    };
