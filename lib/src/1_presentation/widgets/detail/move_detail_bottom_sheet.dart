import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/1_presentation/di/presentation_bloc_factory.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/extensions/pokemon_failure_ext.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_cubit.dart';
import 'package:pokefinder/src/2_application/bloc/move_detail_cubit/move_detail_state.dart';
import 'package:pokefinder/src/3_domain/entities/move_detail.dart';

class MoveDetailBottomSheet extends StatelessWidget {
  const MoveDetailBottomSheet({
    super.key,
    required this.moveName,
    required this.capitalizedName,
  });

  final String moveName;
  final String capitalizedName;

  static void show(
    BuildContext context,
    String moveName,
    String capitalizedName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MoveDetailBottomSheet(
        moveName: moveName,
        capitalizedName: capitalizedName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createMoveDetailCubit(moveName),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  capitalizedName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                BlocBuilder<MoveDetailCubit, MoveDetailState>(
                  builder: (context, state) {
                    if (state is MoveDetailLoading ||
                        state is MoveDetailInitial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is MoveDetailError) {
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
                                      .read<MoveDetailCubit>()
                                      .fetchMoveDetail(moveName);
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(context.t().retryButton),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is MoveDetailLoaded) {
                      return _MoveDetailContent(moveDetail: state.moveDetail);
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

class _MoveDetailContent extends StatelessWidget {
  const _MoveDetailContent({required this.moveDetail});

  final MoveDetail moveDetail;

  @override
  Widget build(BuildContext context) {
    final t = context.t();
    final locale = Localizations.localeOf(context).languageCode;

    final typeName = moveDetail.type != null
        ? context.translateType(moveDetail.type!.apiName)
        : '-';

    final damageClassName = context.translateDamageClass(
      moveDetail.damageClass,
    );

    final effectText =
        moveDetail.flavorTexts[locale] ?? moveDetail.flavorTexts['en'] ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatBadge(label: t.moveDetailType, value: typeName),
            _StatBadge(label: t.moveDetailClass, value: damageClassName),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatBadge(
              label: t.moveDetailPower,
              value: moveDetail.power?.toString() ?? '-',
            ),
            _StatBadge(
              label: t.moveDetailAccuracy,
              value: moveDetail.accuracy?.toString() ?? '-',
            ),
            _StatBadge(
              label: t.moveDetailPP,
              value: moveDetail.pp?.toString() ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          t.moveDetailEffect,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          effectText.replaceAll('\n', ' '),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: primary),
          ),
        ),
      ],
    );
  }
}
