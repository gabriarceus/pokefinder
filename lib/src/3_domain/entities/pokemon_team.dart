import 'package:equatable/equatable.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Maximum number of members held by a single local team.
const kTeamMaxMembers = 6;

/// Maximum length of a user-provided team name (in characters).
const kTeamMaxNameLength = 40;

/// Lightweight bookmark for a team member.
///
/// Stores index refs only (`id`, `name`, sprite, types, timestamp) — never
/// full API payloads. Forms are distinct members when their canonical slugs
/// differ (e.g. `charizard` vs `charizard-mega-x`).
class TeamMember extends Equatable {
  const TeamMember({
    required this.id,
    required this.name,
    required this.spriteUrl,
    this.types = const [],
    required this.addedAt,
  });

  /// Pokédex identifier (forms use IDs above 1025).
  final int id;

  /// Canonical lowercase name slug (e.g. `pikachu`, `charizard-mega-x`).
  final String name;

  /// URL of the default sprite image.
  final String spriteUrl;

  /// Known elemental types at the time the member was added.
  final List<PokemonType> types;

  /// Timestamp when the member joined the team.
  final DateTime addedAt;

  /// Normalized identity key: distinct slugs are distinct members.
  String get memberKey => name.trim().toLowerCase();

  /// Serializes this member to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spriteUrl': spriteUrl,
    'types': types.map((t) => t.apiName).toList(),
    'addedAt': addedAt.toIso8601String(),
  };

  /// Deserializes a member from a JSON map.
  ///
  /// Throws a [FormatException] when required refs are missing so callers
  /// can evict the corrupt record instead of crashing.
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    final rawName = json['name'];
    final name = rawName is String ? rawName.trim() : '';
    if (id == null || id <= 0 || name.isEmpty) {
      throw FormatException('Corrupt team member record: $json');
    }
    final rawTypes = json['types'];
    final typeList = rawTypes is List ? rawTypes : const [];
    final rawSpriteUrl = json['spriteUrl'];
    final rawAddedAt = json['addedAt'];
    return TeamMember(
      id: id,
      name: name,
      spriteUrl: rawSpriteUrl is String ? rawSpriteUrl : '',
      types: typeList
          .map((t) => PokemonType.fromApiName(t.toString()))
          .whereType<PokemonType>()
          .toList(),
      addedAt: rawAddedAt is String
          ? DateTime.tryParse(rawAddedAt) ??
                DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Converts this member into a [PokemonIndexEntry] for card presentation.
  PokemonIndexEntry toIndexEntry() {
    return PokemonIndexEntry(
      id: id,
      name: name,
      detailUrl: 'https://pokeapi.co/api/v2/pokemon/$id/',
      types: types,
      customSpriteUrl: spriteUrl.isNotEmpty ? spriteUrl : null,
    );
  }

  @override
  List<Object?> get props => [id, name, spriteUrl, types, addedAt];
}

/// Local team of up to [kTeamMaxMembers] lightweight member refs.
class PokemonTeam extends Equatable {
  const PokemonTeam({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
  });

  /// Stable team identifier (generated at creation).
  final String id;

  /// User-visible team name.
  final String name;

  /// Timestamp when the team was created.
  final DateTime createdAt;

  /// Timestamp of the last mutation (member add/remove/reorder/rename).
  final DateTime updatedAt;

  /// Members in display order (at most [kTeamMaxMembers]).
  final List<TeamMember> members;

  /// Whether the team holds the maximum number of members.
  bool get isFull => members.length >= kTeamMaxMembers;

  /// Whether another member can be added.
  bool get canAdd => members.length < kTeamMaxMembers;

  /// Serializes this team to a lightweight JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'members': members.map((m) => m.toJson()).toList(),
  };

  /// Deserializes a team from a JSON map.
  ///
  /// Throws a [FormatException] when the team identity is missing so callers
  /// can evict the corrupt record. Corrupt members are skipped individually;
  /// members beyond [kTeamMaxMembers] are truncated to the cap.
  factory PokemonTeam.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is String ? rawId.trim() : rawId?.toString().trim() ?? '';
    final rawName = json['name'];
    final name = rawName is String ? rawName.trim() : '';
    if (id.isEmpty || name.isEmpty) {
      throw FormatException('Corrupt team record: $json');
    }
    final rawMembers = json['members'];
    final memberList = rawMembers is List ? rawMembers : const [];
    final members = <TeamMember>[];
    for (final raw in memberList) {
      if (raw is! Map<String, dynamic>) continue;
      try {
        members.add(TeamMember.fromJson(raw));
      } on FormatException {
        continue;
      }
    }
    final capped = members.length > kTeamMaxMembers
        ? members.sublist(0, kTeamMaxMembers)
        : members;
    final rawCreatedAt = json['createdAt'];
    final rawUpdatedAt = json['updatedAt'];
    return PokemonTeam(
      id: id,
      name: name,
      createdAt: rawCreatedAt is String
          ? DateTime.tryParse(rawCreatedAt) ??
                DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: rawUpdatedAt is String
          ? DateTime.tryParse(rawUpdatedAt) ??
                DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
      members: capped,
    );
  }

  PokemonTeam copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TeamMember>? members,
  }) {
    return PokemonTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, members];
}
