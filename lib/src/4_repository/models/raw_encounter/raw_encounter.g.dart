// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_encounter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawEncounter _$RawEncounterFromJson(Map<String, dynamic> json) => RawEncounter(
  locationArea: NamedAPIResource.fromJson(
    json['location_area'] as Map<String, dynamic>,
  ),
  versionDetails: (json['version_details'] as List<dynamic>)
      .map((e) => RawEncounterVersionDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
);

RawEncounterVersionDetail _$RawEncounterVersionDetailFromJson(
  Map<String, dynamic> json,
) => RawEncounterVersionDetail(
  version: NamedAPIResource.fromJson(json['version'] as Map<String, dynamic>),
);
