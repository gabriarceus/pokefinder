import 'package:material_ui/material_ui.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_name_dialog.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_summary_section.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/1_presentation/widgets/empty_state_view.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Detail screen for one local team: members, type coverage, and stat summary.
///
/// Members deep-link through the canonical `/pokemon/:nameOrId` route.
/// The stat summary fetches the members through one [PokemonListCubit] (via
/// the shared factory, served offline from the Hive cache), so a failure on
/// one member shows inline retry without destroying the rest.
class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key, required this.teamId});

  final String teamId;

  Future<void> _renameTeam(BuildContext context, String current) async {
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

  Future<void> _deleteTeam(BuildContext context, String teamName) async {
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
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        final team = state.teamById(teamId);
        if (team == null) {
          return _TeamNotFoundView();
        }
        final t = context.t();
        final hasDuplicates = TeamSummaryHelper.hasDuplicateMembers(
          team.members,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(
              team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: t.teamRename,
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _renameTeam(context, team.name),
              ),
              IconButton(
                tooltip: t.teamDelete,
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _deleteTeam(context, team.name),
              ),
            ],
          ),
          body: team.members.isEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TeamSummarySection(members: team.members),
                      const SizedBox(height: 12),
                      const _TeamEmptyMembersView(),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(12),
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasDuplicates) const _DuplicateWarningBanner(),
                      if (hasDuplicates) const SizedBox(height: 12),
                      TeamSummarySection(members: team.members),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          '${t.teamMembers} • ${t.teamMembersCount(count: team.members.length)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  itemCount: team.members.length,
                  itemBuilder: (context, index) {
                    final member = team.members[index];
                    return _TeamMemberTile(
                      // Instance identity: stable across reorder, unique even
                      // for duplicate slugs added within the same microsecond.
                      key: ObjectKey(member),
                      teamId: team.id,
                      member: member,
                      index: index,
                    );
                  },
                  onReorderItem: (oldIndex, newIndex) {
                    context.read<TeamsCubit>().reorderMember(
                      team.id,
                      oldIndex,
                      newIndex,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _TeamNotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.t();
    return Scaffold(
      appBar: AppBar(title: Text(t.teamsTitle)),
      body: EmptyStateView(
        icon: Icons.error_outline_rounded,
        title: t.routeNotFoundMessage,
        isError: true,
        action: FilledButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text(t.goHome),
        ),
      ),
    );
  }
}

class _DuplicateWarningBanner extends StatelessWidget {
  const _DuplicateWarningBanner();

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    return Semantics(
      label: '${t.teamDuplicateWarning}. ${t.teamDuplicateMessage}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.teamDuplicateWarning,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.teamDuplicateMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamEmptyMembersView extends StatelessWidget {
  const _TeamEmptyMembersView();

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              t.teamEmptyMembersTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(t.teamEmptyMembersMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(AppRoutes.pokedex),
              child: Text(t.browsePokedex),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({
    super.key,
    required this.teamId,
    required this.member,
    required this.index,
  });

  final String teamId;
  final TeamMember member;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final entry = member.pokemon.toIndexEntry();
    final displayName = context.translatePokemonIndexEntry(entry);
    return Card(
      child: ListTile(
        leading: member.pokemon.spriteUrl.isNotEmpty
            ? Image.network(
                member.pokemon.spriteUrl,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.catching_pokemon, size: 40),
              )
            : const Icon(Icons.catching_pokemon, size: 40),
        title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(entry.formattedId),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0)
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: t.teamMoveToTop,
                  icon: const Icon(Icons.vertical_align_top_rounded),
                  onPressed: () =>
                      context.read<TeamsCubit>().moveMemberToTop(teamId, index),
                ),
              ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: t.teamRemoveMember,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                onPressed: () =>
                    context.read<TeamsCubit>().removeMemberAt(teamId, index),
              ),
            ),
          ],
        ),
        onTap: () => context.push(AppRoutes.pokemon(member.pokemon.name)),
      ),
    );
  }
}
