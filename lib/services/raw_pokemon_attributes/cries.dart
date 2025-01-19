import 'package:json_annotation/json_annotation.dart';

part 'cries.g.dart';

@JsonSerializable()
class Cries {
  const Cries({
    required this.latest,
  });

  @JsonKey(name: 'latest')
  final String latest;

  factory Cries.fromJson(Map<String, dynamic> json) => _$CriesFromJson(json);

  Map<String, dynamic> toJson() => _$CriesToJson(this);
}