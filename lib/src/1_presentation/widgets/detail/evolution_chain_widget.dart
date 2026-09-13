import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/helpers/evolution_trigger_formatter.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/detail_widgets.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/evolution_cubit/evolution_state.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Widget rendering an interactive, branching evolution tree for the current Pokémon.
class EvolutionChainWidget extends StatelessWidget {
  const EvolutionChainWidget({
    super.key,
    required this.evolutionChainUrl,
    required this.currentPokemonName,
    required this.typeColor,
    required this.textColor,
  });

  final String? evolutionChainUrl;
  final String currentPokemonName;
  final Color typeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    if (evolutionChainUrl == null || evolutionChainUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (context) =>
          getIt<EvolutionCubit>()..fetchEvolutionChain(evolutionChainUrl!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t().evolutionChain,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<EvolutionCubit, EvolutionState>(
            builder: (context, state) {
              if (state is EvolutionLoading || state is EvolutionInitial) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is EvolutionError) {
                final errorMessage = state.failure != null
                    ? state.failure!.localizedMessage(context)
                    : state.message;
                return SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            context.read<EvolutionCubit>().fetchEvolutionChain(
                              evolutionChainUrl!,
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: Text(context.t().retryButton),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is EvolutionLoaded) {
                final chain = state.chain;
                if (chain.root.isFinalStage) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      context.t().noEvolutions,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }

                return _EvolutionTreeView(
                  rootNode: chain.root,
                  currentPokemonName: currentPokemonName,
                  typeColor: typeColor,
                  textColor: textColor,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _EvolutionTreeView extends StatelessWidget {
  const _EvolutionTreeView({
    required this.rootNode,
    required this.currentPokemonName,
    required this.typeColor,
    required this.textColor,
  });

  final EvolutionNode rootNode;
  final String currentPokemonName;
  final Color typeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // If the root evolves to multiple branches directly (e.g. Eevee, Tyrogue, Applin)
    if (rootNode.evolvesTo.length > 1) {
      return Column(
        children: [
          _PokemonNodeCard(
            node: rootNode,
            isCurrent:
                rootNode.speciesName.toLowerCase() ==
                currentPokemonName.toLowerCase(),
            typeColor: typeColor,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rootNode.evolvesTo.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final branch = rootNode.evolvesTo[index];
              return _EvolutionStepRow(
                fromNode: rootNode,
                toNode: branch,
                currentPokemonName: currentPokemonName,
                typeColor: typeColor,
                textColor: textColor,
              );
            },
          ),
        ],
      );
    }

    // Linear chain or branched stage 2 (e.g. Gloom -> Vileplume/Bellossom)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _buildChainRow(context, rootNode),
      ),
    );
  }

  Widget _buildChainRow(BuildContext context, EvolutionNode node) {
    if (node.isFinalStage) {
      return _PokemonNodeCard(
        node: node,
        isCurrent:
            node.speciesName.toLowerCase() == currentPokemonName.toLowerCase(),
        typeColor: typeColor,
        textColor: textColor,
      );
    }

    if (node.evolvesTo.length == 1) {
      final nextNode = node.evolvesTo.first;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PokemonNodeCard(
            node: node,
            isCurrent:
                node.speciesName.toLowerCase() ==
                currentPokemonName.toLowerCase(),
            typeColor: typeColor,
            textColor: textColor,
          ),
          _TriggerArrow(
            trigger: nextNode.triggers.firstOrNull,
            typeColor: typeColor,
          ),
          _buildChainRow(context, nextNode),
        ],
      );
    }

    // Stage with multiple branches (e.g. Gloom -> Vileplume / Bellossom)
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PokemonNodeCard(
          node: node,
          isCurrent:
              node.speciesName.toLowerCase() ==
              currentPokemonName.toLowerCase(),
          typeColor: typeColor,
          textColor: textColor,
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: node.evolvesTo.map((branch) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TriggerArrow(
                    trigger: branch.triggers.firstOrNull,
                    typeColor: typeColor,
                  ),
                  _buildChainRow(context, branch),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EvolutionStepRow extends StatelessWidget {
  const _EvolutionStepRow({
    required this.fromNode,
    required this.toNode,
    required this.currentPokemonName,
    required this.typeColor,
    required this.textColor,
  });

  final EvolutionNode fromNode;
  final EvolutionNode toNode;
  final String currentPokemonName;
  final Color typeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: _TriggerBadge(
                trigger: toNode.triggers.firstOrNull,
                typeColor: typeColor,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
            const SizedBox(width: 12),
            _PokemonNodeCard(
              node: toNode,
              isCurrent:
                  toNode.speciesName.toLowerCase() ==
                  currentPokemonName.toLowerCase(),
              typeColor: typeColor,
              textColor: textColor,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PokemonNodeCard extends StatelessWidget {
  const _PokemonNodeCard({
    required this.node,
    required this.isCurrent,
    required this.typeColor,
    required this.textColor,
    this.compact = false,
  });

  final EvolutionNode node;
  final bool isCurrent;
  final Color typeColor;
  final Color textColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final displayName = node.speciesName.capitalize();

    return Semantics(
      button: !isCurrent,
      selected: isCurrent,
      label: isCurrent
          ? '$displayName, ${context.t().currentPokemon}'
          : displayName,
      child: InkWell(
        onTap: () {
          if (!isCurrent) {
            context.push('/pokemon/${node.speciesName}');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: compact ? 88 : 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrent
                ? typeColor.withValues(alpha: 0.15)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? typeColor : Colors.transparent,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: compact ? 48 : 64,
                height: compact ? 48 : 64,
                child: Image.network(
                  node.spriteUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.catching_pokemon,
                    size: compact ? 32 : 40,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? typeColor : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriggerArrow extends StatelessWidget {
  const _TriggerArrow({required this.trigger, required this.typeColor});

  final EvolutionTriggerDetail? trigger;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final label = trigger != null
        ? EvolutionTriggerFormatter.format(trigger!, l10n: context.t())
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: typeColor.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _TriggerBadge extends StatelessWidget {
  const _TriggerBadge({required this.trigger, required this.typeColor});

  final EvolutionTriggerDetail? trigger;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    if (trigger == null) return const SizedBox.shrink();

    final label = EvolutionTriggerFormatter.format(trigger!, l10n: context.t());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: typeColor,
        ),
      ),
    );
  }
}
