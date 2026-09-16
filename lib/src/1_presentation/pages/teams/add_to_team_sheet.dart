import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_name_dialog.dart';
import 'package:pokefinder/src/2_application/bloc/teams_cubit/teams_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Outcome of an add-to-team sheet flow.
class AddToTeamOutcome {
  const AddToTeamOutcome({
    required this.result,
    required this.teamId,
    required this.teamName,
  });

  final TeamAddMemberResult result;
  final String teamId;
  final String teamName;
}

/// Shows a bottom sheet to add [entry] to a local team.
///
/// Creates the team inline when needed, then reports the outcome with a
/// snackbar on the caller's scaffold: confirmation with a view action on
/// success (duplicate slugs included, flagged inline), guidance when the
/// team is full.
Future<void> showAddToTeamSheet(
  BuildContext context,
  PokemonIndexEntry entry,
) async {
  TeamsCubit? cubit;
  try {
    cubit = context.read<TeamsCubit>();
  } catch (_) {
    return;
  }
  final capturedCubit = cubit;
  if (!context.mounted) return;
  final outcome = await showModalBottomSheet<AddToTeamOutcome>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => BlocProvider.value(
      value: capturedCubit,
      child: _AddToTeamSheet(entry: entry),
    ),
  );
  if (outcome == null || !context.mounted) return;
  final t = context.t();
  final messenger = ScaffoldMessenger.of(context);
  switch (outcome.result) {
    case TeamAddMemberResult.added:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(t.teamAddedTo(team: outcome.teamName)),
            action: SnackBarAction(
              label: t.teamView,
              onPressed: () {
                if (context.mounted) {
                  context.push('/teams/${outcome.teamId}');
                }
              },
            ),
          ),
        );
    case TeamAddMemberResult.addedWithDuplicateWarning:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${t.teamAddedTo(team: outcome.teamName)} — ${t.teamDuplicateWarning}',
            ),
            action: SnackBarAction(
              label: t.teamView,
              onPressed: () {
                if (context.mounted) {
                  context.push('/teams/${outcome.teamId}');
                }
              },
            ),
          ),
        );
    case TeamAddMemberResult.teamFull:
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.teamFull)));
    case TeamAddMemberResult.teamNotFound:
      break;
  }
}

class _AddToTeamSheet extends StatelessWidget {
  const _AddToTeamSheet({required this.entry});

  final PokemonIndexEntry entry;

  Future<void> _createAndAdd(BuildContext context) async {
    final t = context.t();
    final name = await showTeamNameDialog(
      context,
      title: t.teamCreateTitle,
      confirmLabel: t.teamCreate,
    );
    if (name == null || !context.mounted) return;
    final cubit = context.read<TeamsCubit>();
    final teamId = cubit.createTeam(name);
    final result = cubit.addMember(teamId: teamId, entry: entry);
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pop(AddToTeamOutcome(result: result, teamId: teamId, teamName: name));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.teamPickTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (state.teams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(t.teamPickEmpty),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.teams.length,
                      itemBuilder: (context, index) {
                        final team = state.teams[index];
                        return ListTile(
                          leading: const Icon(Icons.groups_rounded),
                          title: Text(
                            team.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            t.teamMembersCount(count: team.members.length),
                          ),
                          trailing: team.isFull
                              ? Tooltip(
                                  message: t.teamFull,
                                  child: const Icon(Icons.block_rounded),
                                )
                              : null,
                          onTap: () {
                            final result = context.read<TeamsCubit>().addMember(
                              teamId: team.id,
                              entry: entry,
                            );
                            Navigator.of(context).pop(
                              AddToTeamOutcome(
                                result: result,
                                teamId: team.id,
                                teamName: team.name,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                const Divider(height: 16),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(t.teamCreate),
                  onTap: () => _createAndAdd(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
