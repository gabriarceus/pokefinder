import 'package:json_annotation/json_annotation.dart';

part 'cries.g.dart';

@JsonSerializable()
class Cries {
  const Cries({
    required this.latest,
    required this.legacy,
  });

  @JsonKey(name: 'latest')
  final String latest;

  @JsonKey(name: 'legacy')
  final String? legacy;

  factory Cries.fromJson(Map<String, dynamic> json) => _$CriesFromJson(json);

  Map<String, dynamic> toJson() => _$CriesToJson(this);
}
