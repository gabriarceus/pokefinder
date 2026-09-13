import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/ability_detail_cubit/ability_detail_state.dart';
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
      create: (context) =>
          getIt<AbilityDetailCubit>()..fetchAbilityDetail(abilityName),
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
                      style: const TextStyle(
                        fontSize: 22,
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
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          context.t().abilityHidden.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<AbilityDetailCubit, AbilityDetailState>(
                  builder: (context, state) {
                    if (state is AbilityDetailLoading ||
                        state is AbilityDetailInitial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is AbilityDetailError) {
                      final errorMessage = state.failure != null
                          ? state.failure!.localizedMessage(context)
                          : state.message;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context
                                      .read<AbilityDetailCubit>()
                                      .fetchAbilityDetail(abilityName);
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(context.t().retryButton),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is AbilityDetailLoaded) {
                      return _AbilityDetailContent(
                        abilityDetail: state.abilityDetail,
                      );
                    }
                    return const SizedBox.shrink();
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          t.abilityEffect,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }
}
