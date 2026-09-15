import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Parses the `types` query parameter for the `/matchups` route.
///
/// Accepts comma-separated API slugs (e.g. `fire,flying`), keeps the first
/// two recognized battle types, and drops anything else (including stellar).
List<PokemonType> parseMatchupTypesParam(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final seen = <PokemonType>[];
  for (final part in raw.split(',')) {
    final type = PokemonType.fromApiName(part.trim().toLowerCase());
    if (type == null) continue;
    if (!TypeMatchupChart.battleTypes.contains(type)) continue;
    if (seen.contains(type)) continue;
    seen.add(type);
    if (seen.length >= 2) break;
  }
  return seen;
}

/// Builds the canonical `/matchups` path for 1–2 defending types.
String buildMatchupPath(List<PokemonType> defending) {
  if (defending.isEmpty) return '/matchups';
  final slugs = defending
      .where(TypeMatchupChart.battleTypes.contains)
      .take(2)
      .map((t) => t.apiName)
      .join(',');
  return slugs.isEmpty ? '/matchups' : '/matchups?types=$slugs';
}

/// Offline type matchup calculator for 1–2 defending types.
///
/// Purely local: multipliers come from [TypeMatchupChart], so there is no
/// loading, failure, or retry state. An empty selection renders the empty
/// state; any selection renders grouped weaknesses, resistances, and
/// immunities.
class MatchupPage extends StatefulWidget {
  const MatchupPage({super.key, this.initialDefending = const []});

  final List<PokemonType> initialDefending;

  @override
  State<MatchupPage> createState() => _MatchupPageState();
}

class _MatchupPageState extends State<MatchupPage> {
  late List<PokemonType> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDefending
        .where(TypeMatchupChart.battleTypes.contains)
        .toSet()
        .take(2)
        .toList();
  }

  @override
  void didUpdateWidget(covariant MatchupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.initialDefending, widget.initialDefending)) {
      _selected = widget.initialDefending
          .where(TypeMatchupChart.battleTypes.contains)
          .toSet()
          .take(2)
          .toList();
    }
  }

  void _toggle(PokemonType type) {
    setState(() {
      if (_selected.contains(type)) {
        _selected = _selected.where((t) => t != type).toList();
      } else if (_selected.length < 2) {
        _selected = [..._selected, type];
      } else {
        _selected = [_selected[1], type];
      }
    });
  }

  void _clear() {
    setState(() {
      _selected = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final defendingNames = _selected
        .map((t) => context.translateType(t.apiName))
        .join(', ');
    return Scaffold(
      appBar: AppBar(title: Text(context.t().matchupTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              label: defendingNames.isEmpty
                  ? context.t().matchupDefendingTypes
                  : '${context.t().matchupDefendingTypes}: $defendingNames',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t().matchupDefendingTypes,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.t().matchupDefendingHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in TypeMatchupChart.battleTypes)
                  _DefendingTypeOption(
                    type: type,
                    selected: _selected.contains(type),
                    onTap: () => _toggle(type),
                  ),
              ],
            ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: _clear,
                  child: Text(context.t().matchupClearSelection),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (_selected.isEmpty)
              _MatchupEmptyView()
            else
              _MatchupResults(selected: List.unmodifiable(_selected)),
          ],
        ),
      ),
    );
  }
}

/// Selectable defending type chip with a 48×48 touch target.
class _DefendingTypeOption extends StatelessWidget {
  const _DefendingTypeOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PokemonType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeName = context.translateType(type.apiName);
    final baseColor = TypeColorScheme.getColorFromType(type);
    final textColor = selected
        ? contrastingTextColor(baseColor)
        : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: typeName,
      excludeSemantics: true,
      child: Tooltip(
        message: typeName,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? baseColor : baseColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: selected ? 3 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  Text(
                    typeName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grouped matchup results for the selected defending types.
class _MatchupResults extends StatelessWidget {
  const _MatchupResults({required this.selected});

  final List<PokemonType> selected;

  @override
  Widget build(BuildContext context) {
    final groups = TypeMatchupGroups.forDefending(
      selected.first,
      selected.length > 1 ? selected[1] : null,
    );
    final entries = <({String label, List<PokemonType> types})>[
      (label: context.t().matchupGroup4x, types: groups.quadWeak),
      (label: context.t().matchupGroup2x, types: groups.weak),
      (label: context.t().matchupGroupHalf, types: groups.resistant),
      (label: context.t().matchupGroupQuarter, types: groups.doubleResistant),
      (label: context.t().matchupGroupImmune, types: groups.immune),
    ].where((e) => e.types.isNotEmpty).toList();
    if (entries.isEmpty) {
      return _MatchupEmptyView();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _MatchupGroup(label: entries[i].label, types: entries[i].types),
          if (i != entries.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

/// One multiplier group with an announcing semantics label.
class _MatchupGroup extends StatelessWidget {
  const _MatchupGroup({required this.label, required this.types});

  final String label;
  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final names = types.map((t) => context.translateType(t.apiName)).join(', ');
    return Semantics(
      label: '$label: $names',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label (${types.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final type in types) TypeChip(type: type)],
          ),
        ],
      ),
    );
  }
}

class _MatchupEmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            context.t().matchupEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(context.t().matchupEmptyMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => context.push('/pokedex'),
            child: Text(context.t().browsePokedex),
          ),
        ],
      ),
    );
  }
}
