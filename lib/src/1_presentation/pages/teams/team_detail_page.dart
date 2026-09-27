import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/teams/team_name_dialog.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/1_presentation/widgets/dialogs/confirmation_dialog.dart';
import 'package:pokefinder/src/1_presentation/widgets/section_title.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Detail screen for one local team: members, type coverage, and stat summary.
///
/// Members deep-link through the canonical `/pokemon/:nameOrId` route.
/// The stat summary fetches each member through its own [PokemonDetailBloc] (via
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
                      _TeamSummarySection(members: team.members),
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
                      _TeamSummarySection(members: team.members),
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
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) newIndex -= 1;
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                t.routeNotFoundMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(t.goHome),
              ),
            ],
          ),
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

/// Type coverage plus summed/average base stats for [members].
///
/// Both sections read the same fetched [Pokemon]s, so one widget owns the
/// fetch: the stored member refs carry no types unless the member was added
/// from a detail screen, and coverage can only be complete once they resolve.
class _TeamSummarySection extends StatefulWidget {
  const _TeamSummarySection({required this.members});

  final List<TeamMember> members;

  @override
  State<_TeamSummarySection> createState() => _TeamSummarySectionState();
}

class _TeamSummarySectionState extends State<_TeamSummarySection> {
  List<PokemonDetailBloc> _blocs = const [];
  List<StreamSubscription<PokemonBlocState>> _subscriptions = const [];
  List<Pokemon?> _pokemons = const [];
  List<bool> _failed = const [];

  @override
  void initState() {
    super.initState();
    _initBlocs();
  }

  @override
  void didUpdateWidget(covariant _TeamSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameMemberOrder(oldWidget.members, widget.members)) {
      _disposeBlocs();
      _initBlocs();
    }
  }

  static bool _sameMemberOrder(List<TeamMember> a, List<TeamMember> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _initBlocs() {
    final blocs = <PokemonDetailBloc>[
      for (final member in widget.members)
        createPokemonBloc(member.pokemon.name),
    ];
    _blocs = blocs;
    _pokemons = List<Pokemon?>.filled(blocs.length, null);
    _failed = List<bool>.filled(blocs.length, false);
    _subscriptions = [
      for (final bloc in blocs) bloc.stream.listen((_) => _refresh()),
    ];
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    var changed = false;
    for (var i = 0; i < _blocs.length; i++) {
      final state = _blocs[i].state;
      final pokemon = state is PokemonBlocSuccess ? state.pokemon : null;
      final failed = state is PokemonBlocFailure;
      if (_pokemons[i] != pokemon || _failed[i] != failed) {
        _pokemons[i] = pokemon;
        _failed[i] = failed;
        changed = true;
      }
    }
    if (changed) setState(() {});
  }

  void _disposeBlocs() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    for (final bloc in _blocs) {
      bloc.close();
    }
    _subscriptions = const [];
    _blocs = const [];
    _pokemons = const [];
    _failed = const [];
  }

  @override
  void dispose() {
    _disposeBlocs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final locale = Localizations.localeOf(context).languageCode;
    final loaded = _pokemons.whereType<Pokemon>().toList();
    final isLoading = loaded.isEmpty && !_failed.contains(true);
    // The stored refs are a usable answer only until the fetched members land.
    final coverage = loaded.isEmpty
        ? TeamSummaryHelper.typeCoverage(widget.members)
        : TeamSummaryHelper.typeCoverageOfPokemons(loaded);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionTitle(t.teamSummary),
            Text(
              t.teamTypeCoverage,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (coverage.isEmpty)
              Text(isLoading ? '' : t.noData)
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final type in coverage) TypeChip(type: type)],
              ),
            const Divider(height: 24),
            Text(t.baseStats, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _buildStats(context, t, locale, loaded, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AppLocalizations t,
    String locale,
    List<Pokemon> loaded,
    bool isLoading,
  ) {
    if (widget.members.isEmpty) return Text(t.statsNotAvailable);
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final summary = TeamSummaryHelper.buildStatSummary(loaded);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.isEmpty)
          Text(t.statsNotAvailable)
        else ...[
          // Names the two columns, which are otherwise only implied by the
          // per-row layout.
          _TeamStatHeader(
            sumLabel: t.teamStatsSumColumn,
            statLabel: t.baseStats,
            averageLabel: t.teamStatsAverageColumn,
          ),
          for (var i = 0; i < StatKind.values.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TeamStatRow(
                kind: StatKind.values[i],
                sum: summary.sums[i],
                average: summary.averages[i],
                locale: locale,
              ),
            ),
          const Divider(height: 16),
          Text(
            '${t.teamStatsSum}: ${MeasurementFormatter.formatInteger(summary.totalSum, locale: locale)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${t.teamStatsAverage}: ${NumberFormat('0.0', locale).format(summary.totalAverage)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
        for (var i = 0; i < widget.members.length; i++)
          if (_failed[i])
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.members[i].pokemon.name)),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      tooltip: t.retryButton,
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => _blocs[i].add(
                        FetchPokemonEvent(widget.members[i].pokemon.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Column header naming the summed and averaged stat of every row below.
class _TeamStatHeader extends StatelessWidget {
  const _TeamStatHeader({
    required this.sumLabel,
    required this.statLabel,
    required this.averageLabel,
  });

  final String sumLabel;
  final String statLabel;
  final String averageLabel;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(sumLabel, style: style)),
          Expanded(
            child: Text(statLabel, textAlign: TextAlign.center, style: style),
          ),
          SizedBox(
            width: 56,
            child: Text(averageLabel, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// One summed/average stat row reusing the comparison stat components.
class _TeamStatRow extends StatelessWidget {
  const _TeamStatRow({
    required this.kind,
    required this.sum,
    required this.average,
    required this.locale,
  });

  final StatKind kind;
  final int sum;
  final double average;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = statKindLabel(context, kind);
    final formattedSum = MeasurementFormatter.formatInteger(
      sum,
      locale: locale,
    );
    final formattedAverage = NumberFormat('0.0', locale).format(average);
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium;

    return Semantics(
      label: '$label: sum $formattedSum, average $formattedAverage',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 56, child: Text(formattedSum, style: baseStyle)),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  formattedAverage,
                  textAlign: TextAlign.right,
                  style: baseStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (average / 255.0).clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: statBarColor(average.round()),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
