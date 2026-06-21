import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/damage_class.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

class MoveDetail extends Equatable {
  const MoveDetail({
    required this.id,
    required this.name,
    this.accuracy,
    this.power,
    this.pp,
    required this.type,
    this.damageClass,
    required this.flavorTexts,
  });

  final int id;
  final String name;
  final int? accuracy;
  final int? power;
  final int? pp;
  final PokemonType? type;
  final DamageClass? damageClass;
  final Map<String, String> flavorTexts;

  @override
  List<Object?> get props => [
        id,
        name,
        accuracy,
        power,
        pp,
        type,
        damageClass,
        flavorTexts,
      ];
}
