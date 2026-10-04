import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/widgets/detail_tab_scroll_view.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/entities/learn_method.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

/// Moves tab of the detail page, filtered by the selected game version.
class DetailMovesTab extends StatelessWidget {
  const DetailMovesTab({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      // Moves and localized names are captured when the cubit is created.
      key: ValueKey((pokemon.id, languageCode)),
      create: (context) => createDetailMovesCubit(
        moves: pokemon.moves,
        moveName: MoveNameResolver(
          (slug) => translateMoveSlug(slug, languageCode),
        ),
        gameVersion: context
            .read<DetailGameVersionCubit>()
            .state
            .selectedVersion,
      ),
      child: BlocListener<DetailGameVersionCubit, DetailGameVersionState>(
        listenWhen: (previous, current) =>
            previous.selectedVersion != current.selectedVersion,
        listener: (context, state) => context
            .read<DetailMovesCubit>()
            .selectGameVersion(state.selectedVersion),
        child: const _DetailMovesTabContent(),
      ),
    );
  }
}

class _DetailMovesTabContent extends StatelessWidget {
  const _DetailMovesTabContent();

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final cubit = context.read<DetailMovesCubit>();
    final isFilteringBySpecificGame = context
        .select<DetailGameVersionCubit, bool>(
          (versionCubit) => !versionCubit.state.isAllVersions,
        );

    return BlocBuilder<DetailMovesCubit, DetailMovesState>(
      builder: (context, state) {
        return DetailTabScrollView(
          storageKey: 'detail_moves',
          slivers: [
            SliverList.list(
              children: [
                DetailGameVersionSelector(
                  typeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: t.movesSearchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: cubit.updateSearchQuery,
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final method in state.availableMethods)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_methodFilterLabel(context, method)),
                            selected: state.selectedMethod == method,
                            onSelected: (selected) {
                              if (selected) cubit.updateSelectedMethod(method);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            if (state.filteredMoves.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isFilteringBySpecificGame && state.searchQuery.isEmpty
                        ? t.movesUnavailableForVersion
                        : t.movesSearchEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: state.filteredMoves.length,
                itemBuilder: (context, index) =>
                    _MoveTile(move: state.filteredMoves[index]),
              ),
          ],
        );
      },
    );
  }

  String _methodFilterLabel(BuildContext context, String method) {
    final t = context.t();
    if (method == DetailMovesCubit.allMethodsFilter) return t.movesFilterAll;
    return switch (LearnMethod.fromApi(method)) {
      LearnMethod.levelUp => t.movesFilterLevelUp,
      LearnMethod.machine => t.movesFilterMachine,
      LearnMethod.tutor => t.movesFilterTutor,
      LearnMethod.egg => t.movesFilterEgg,
      null => method.toDisplayCase(),
    };
  }
}

class _MoveTile extends StatelessWidget {
  const _MoveTile({required this.move});

  final PokemonMove move;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final theme = Theme.of(context);
    final name = context.translateMove(move.name);
    final learnDetail = switch (LearnMethod.fromApi(move.learnMethod)) {
      LearnMethod.levelUp => t.moveBadgeLevel(level: move.levelLearnedAt),
      LearnMethod.machine => t.movesFilterMachine,
      LearnMethod.tutor => t.moveBadgeTutor,
      LearnMethod.egg => t.movesFilterEgg,
      null => move.learnMethod.toDisplayCase(),
    };

    return SurfaceCard(
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => MoveDetailBottomSheet.show(context, move.name, name),
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            learnDetail,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
