import 'package:equatable/equatable.dart';

/// Domain model for a Pokemon
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.sprite,
    required this.ability1,
    required this.ability2,
    required this.ability3,
    required this.weight,
    required this.height,
    required this.typeImage1,
    required this.typeImage2,
    required this.type1,
    required this.type2,
    required this.cry,
  });

  final int id;
  final String name;
  final String typeImage1;
  final String typeImage2;
  final String type1;
  final String? type2;
  final String sprite;
  final String ability1;
  final String ability2;
  final String ability3;
  final String cry;

  /// [weight] is the weight of the Pokemon in hectograms
  final double weight;

  /// [height] is the height of the Pokemon in decimetres
  final double height;

  @override
  List<Object?> get props => [
        id,
        name,
        sprite,
        ability1,
        ability2,
        ability3,
        weight,
        height,
        typeImage1,
        typeImage2,
        type1,
        type2,
        cry,
      ];
}
