import 'package:json_annotation/json_annotation.dart';

part 'named_api_resource.g.dart';

@JsonSerializable(createToJson: false)
class NamedAPIResource {
  const NamedAPIResource({required this.name, required this.url});

  final String name;
  final String url;

  factory NamedAPIResource.fromJson(Map<String, dynamic> json) =>
      _$NamedAPIResourceFromJson(json);
}
