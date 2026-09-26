import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_name_dialog.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/1_presentation/widgets/empty_state_view.dart';
import 'package:pokefinder/src/2_application/bloc/teams_cubit/teams_cubit.dart';

/// Screen listing locally stored teams with create, rename, and delete flows.
class TeamsListPage extends StatelessWidget {
  const TeamsListPage({super.key});

  Future<void> _createTeam(BuildContext context) async {
    final t = context.t();
    final name = await showTeamNameDialog(
      context,
      title: t.teamCreateTitle,
      confirmLabel: t.teamCreate,
    );
    if (name == null || !context.mounted) return;
    final teamId = context.read<TeamsCubit>().createTeam(name);
    if (!context.mounted) return;
    context.push(AppRoutes.team(teamId));
  }

  Future<void> _renameTeam(
    BuildContext context,
    String teamId,
    String current,
  ) async {
    final t = context.t();
    final name = await showTeamNameDialog(
      context,
      title: t.teamRename,
      confirmLabel: t.teamRename,
      initialName: current,
    );
    if (name == null || !context.mounted) return;
    context.read<TeamsCubit>().renameTeam(teamId, name);
  }

  Future<void> _deleteTeam(
    BuildContext context,
    String teamId,
    String teamName,
  ) async {
    final t = context.t();
    final confirmed = await showConfirmationDialog(
      context: context,
      title: t.teamDeleteTitle,
      content: t.teamDeleteMessage(name: teamName),
      confirmLabel: t.teamDelete,
      cancelLabel: t.cancel,
    );
    if (confirmed == true && context.mounted) {
      context.read<TeamsCubit>().deleteTeam(teamId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    return Scaffold(
      appBar: AppBar(
        title: Text(t.teamsTitle),
        actions: [
          IconButton(
            tooltip: t.teamCreate,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _createTeam(context),
          ),
        ],
      ),
      body: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, state) {
          if (state.teams.isEmpty) {
            return _TeamsEmptyView(onCreate: () => _createTeam(context));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.teams.length,
            itemBuilder: (context, index) {
              final team = state.teams[index];
              return Card(
                key: ValueKey('team-${team.id}'),
                child: ListTile(
                  leading: Icon(
                    Icons.groups_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    t.teamMembersCount(count: team.members.length),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _renameTeam(context, team.id, team.name);
                      } else if (value == 'delete') {
                        _deleteTeam(context, team.id, team.name);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.edit_rounded),
                          title: Text(t.teamRename),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.delete_rounded),
                          title: Text(t.teamDelete),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.push(AppRoutes.team(team.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<TeamsCubit, TeamsState>(
        builder: (context, state) {
          if (state.teams.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _createTeam(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.teamCreate),
          );
        },
      ),
    );
  }
}

class _TeamsEmptyView extends StatelessWidget {
  const _TeamsEmptyView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    return EmptyStateView(
      icon: Icons.groups_rounded,
      title: t.teamsEmptyTitle,
      message: t.teamsEmptyMessage,
      action: FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add_rounded),
        label: Text(t.teamCreate),
      ),
    );
  }
}
