import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/types/type.dart';

part 'type_container.g.dart';

@JsonSerializable()
class TypeContainer {
  const TypeContainer({
    required this.type,
  });

  final Type type;

  factory TypeContainer.fromJson(Map<String, dynamic> json) =>
      _$TypeContainerFromJson(json);

  Map<String, dynamic> toJson() => _$TypeContainerToJson(this);
}
