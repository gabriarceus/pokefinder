import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/failure_retry_card.dart';
import 'package:pokefinder/src/2_application/bloc/load_cubit/load_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/load_cubit/load_state.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';

/// Modal bottom sheet displaying detailed behavior and in-battle effects for a Pokémon ability.
class AbilityDetailBottomSheet extends StatelessWidget {
  const AbilityDetailBottomSheet({
    super.key,
    required this.abilityName,
    required this.displayName,
    this.isHidden = false,
  });

  final String abilityName;
  final String displayName;
  final bool isHidden;

  static void show(
    BuildContext context, {
    required String abilityName,
    required String displayName,
    bool isHidden = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AbilityDetailBottomSheet(
        abilityName: abilityName,
        displayName: displayName,
        isHidden: isHidden,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createAbilityDetailCubit(abilityName),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isHidden) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.t().abilityHidden.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<LoadCubit<AbilityDetail>, LoadState<AbilityDetail>>(
                  builder: (context, state) => switch (state) {
                    LoadInProgress() => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    LoadFailure(:final failure) => FailureRetryCard(
                      message: failure.localizedMessage(context),
                      onRetry: () =>
                          context.read<LoadCubit<AbilityDetail>>().load(),
                    ),
                    LoadSuccess(:final value) => _AbilityDetailContent(
                      abilityDetail: value,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AbilityDetailContent extends StatelessWidget {
  const _AbilityDetailContent({required this.abilityDetail});

  final AbilityDetail abilityDetail;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final locale = Localizations.localeOf(context).languageCode;
    final summary = abilityDetail.descriptionFor(locale);
    final battleEffect = abilityDetail.effectFor(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (summary.isNotEmpty) ...[
          Text(
            t.abilityShortEffect,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              summary,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          t.abilityEffect,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            battleEffect.isNotEmpty ? battleEffect : '-',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}
