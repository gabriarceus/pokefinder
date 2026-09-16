import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Outcome of [TeamsCubit.addMember].
enum TeamAddMemberResult {
  /// Member was added; no duplicate slug existed.
  added,

  /// Member was added but the slug already exists (warning, not a block).
  addedWithDuplicateWarning,

  /// No team matches the requested id.
  teamNotFound,

  /// Team already holds [kTeamMaxMembers] members.
  teamFull,
}

/// State of locally stored teams.
class TeamsState extends Equatable {
  const TeamsState({this.teams = const []});

  /// All teams in creation order.
  final List<PokemonTeam> teams;

  /// Looks up a team by [id], or returns null when absent.
  PokemonTeam? teamById(String id) {
    for (final team in teams) {
      if (team.id == id) return team;
    }
    return null;
  }

  TeamsState copyWith({List<PokemonTeam>? teams}) {
    return TeamsState(teams: teams ?? this.teams);
  }

  @override
  List<Object?> get props => [teams];
}

/// Manages durable local teams of lightweight member refs.
///
/// Teams persist through [HydratedCubit] storage so they survive restart.
/// Members are index refs only — full details are fetched on demand by the
/// team detail screen. The 6-member cap is a hard reject; duplicate slugs
/// are allowed with a warning so forms (distinct slugs) stay distinct.
@lazySingleton
class TeamsCubit extends HydratedCubit<TeamsState> {
  TeamsCubit(this._logger, {Clock clock = const Clock()})
    : _clock = clock,
      super(const TeamsState());

  static const _prefix = 'TeamsCubit';
  final EnLogger _logger;
  final Clock _clock;

  /// Creates a team named [name] and returns its stable id.
  String createTeam(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Team name must not be empty');
    }
    final displayName = trimmed.length > kTeamMaxNameLength
        ? trimmed.substring(0, kTeamMaxNameLength)
        : trimmed;
    final now = _clock.now();
    var id = '${now.microsecondsSinceEpoch}-${state.teams.length}';
    var collision = 0;
    while (state.teamById(id) != null) {
      collision += 1;
      id = '${now.microsecondsSinceEpoch}-${state.teams.length}-$collision';
    }
    final team = PokemonTeam(
      id: id,
      name: displayName,
      createdAt: now,
      updatedAt: now,
      members: const [],
    );
    _logger.info('Creating team: $displayName ($id)', prefix: _prefix);
    emit(state.copyWith(teams: [...state.teams, team]));
    return id;
  }

  /// Renames the team [teamId] to [newName]; returns false when absent/invalid.
  bool renameTeam(String teamId, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;
    final displayName = trimmed.length > kTeamMaxNameLength
        ? trimmed.substring(0, kTeamMaxNameLength)
        : trimmed;
    final index = state.teams.indexWhere((team) => team.id == teamId);
    if (index == -1) return false;
    _logger.info('Renaming team $teamId to $displayName', prefix: _prefix);
    final updated = List<PokemonTeam>.from(state.teams);
    updated[index] = updated[index].copyWith(
      name: displayName,
      updatedAt: _clock.now(),
    );
    emit(state.copyWith(teams: updated));
    return true;
  }

  /// Deletes the team [teamId]; returns true when a team was removed.
  bool deleteTeam(String teamId) {
    if (state.teamById(teamId) == null) return false;
    _logger.info('Deleting team $teamId', prefix: _prefix);
    emit(
      state.copyWith(
        teams: state.teams.where((team) => team.id != teamId).toList(),
      ),
    );
    return true;
  }

  /// Adds [entry] to the team [teamId].
  TeamAddMemberResult addMember({
    required String teamId,
    required PokemonIndexEntry entry,
  }) {
    final team = state.teamById(teamId);
    if (team == null) return TeamAddMemberResult.teamNotFound;
    if (team.isFull) {
      _logger.info(
        'Team $teamId full, rejecting ${entry.name}',
        prefix: _prefix,
      );
      return TeamAddMemberResult.teamFull;
    }
    final duplicate = TeamSummaryHelper.isDuplicateName(
      team.members,
      entry.name,
    );
    final member = TeamMember(
      id: entry.id,
      name: entry.name,
      spriteUrl: entry.spriteUrl,
      types: List<PokemonType>.from(entry.types),
      addedAt: _clock.now(),
    );
    _logger.info(
      'Adding ${entry.name} (#${entry.id}) to team $teamId',
      prefix: _prefix,
    );
    _replaceTeam(
      team.copyWith(
        members: [...team.members, member],
        updatedAt: _clock.now(),
      ),
    );
    return duplicate
        ? TeamAddMemberResult.addedWithDuplicateWarning
        : TeamAddMemberResult.added;
  }

  /// Removes the member at [index] from the team [teamId].
  bool removeMemberAt(String teamId, int index) {
    final team = state.teamById(teamId);
    if (team == null) return false;
    if (index < 0 || index >= team.members.length) return false;
    final removed = team.members[index];
    _logger.info('Removing ${removed.name} from team $teamId', prefix: _prefix);
    final updated = List<TeamMember>.from(team.members)..removeAt(index);
    _replaceTeam(team.copyWith(members: updated, updatedAt: _clock.now()));
    return true;
  }

  /// Removes the first member matching [memberName] (normalized slug).
  bool removeMember(String teamId, String memberName) {
    final team = state.teamById(teamId);
    if (team == null) return false;
    final key = TeamSummaryHelper.normalizeMemberKey(memberName);
    final index = team.members.indexWhere((member) => member.memberKey == key);
    if (index == -1) return false;
    return removeMemberAt(teamId, index);
  }

  /// Moves the member from [oldIndex] to [newIndex] within team [teamId].
  ///
  /// [newIndex] is the final position (already adjusted for removal).
  bool reorderMember(String teamId, int oldIndex, int newIndex) {
    final team = state.teamById(teamId);
    if (team == null) return false;
    if (oldIndex < 0 ||
        oldIndex >= team.members.length ||
        newIndex < 0 ||
        newIndex >= team.members.length) {
      return false;
    }
    if (oldIndex == newIndex) return true;
    final updated = List<TeamMember>.from(team.members);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    _logger.info(
      'Reordering team $teamId member $oldIndex -> $newIndex',
      prefix: _prefix,
    );
    _replaceTeam(team.copyWith(members: updated, updatedAt: _clock.now()));
    return true;
  }

  /// Moves the member at [index] to the top of team [teamId].
  bool moveMemberToTop(String teamId, int index) {
    return reorderMember(teamId, index, 0);
  }

  void _replaceTeam(PokemonTeam updated) {
    emit(
      state.copyWith(
        teams: state.teams
            .map((team) => team.id == updated.id ? updated : team)
            .toList(),
      ),
    );
  }

  @override
  TeamsState fromJson(Map<String, dynamic> json) {
    final rawTeams = json['teams'];
    final teamList = rawTeams is List ? rawTeams : const [];
    final teams = <PokemonTeam>[];
    for (final raw in teamList) {
      if (raw is! Map<String, dynamic>) {
        _logger.info('Evicting corrupt team record', prefix: _prefix);
        continue;
      }
      try {
        teams.add(PokemonTeam.fromJson(raw));
      } catch (_) {
        _logger.info('Evicting corrupt team record', prefix: _prefix);
        continue;
      }
    }
    return TeamsState(teams: teams);
  }

  @override
  Map<String, dynamic> toJson(TeamsState state) => {
    'teams': state.teams.map((team) => team.toJson()).toList(),
  };
}
