import 'package:json_annotation/json_annotation.dart';
import 'package:pokefinder/src/4_repository/models/raw_pokemon/attributes/named_api_resource.dart';

part 'raw_encounter.g.dart';

/// Raw data for a single location-area encounter entry.
@JsonSerializable(explicitToJson: true)
class RawEncounter {
  const RawEncounter({
    required this.locationArea,
    required this.versionDetails,
  });

  @JsonKey(name: 'location_area')
  final NamedAPIResource locationArea;

  @JsonKey(name: 'version_details')
  final List<RawEncounterVersionDetail> versionDetails;

  factory RawEncounter.fromJson(Map<String, dynamic> json) =>
      _$RawEncounterFromJson(json);

  Map<String, dynamic> toJson() => _$RawEncounterToJson(this);
}

/// Version-specific detail for an encounter entry.
@JsonSerializable(explicitToJson: true)
class RawEncounterVersionDetail {
  const RawEncounterVersionDetail({
    required this.version,
  });

  final NamedAPIResource version;

  factory RawEncounterVersionDetail.fromJson(Map<String, dynamic> json) =>
      _$RawEncounterVersionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RawEncounterVersionDetailToJson(this);
}
