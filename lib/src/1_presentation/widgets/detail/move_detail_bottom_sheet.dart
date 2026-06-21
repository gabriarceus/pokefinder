import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
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

  static void show(BuildContext context, String moveName, String capitalizedName) {
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
      create: (context) => MoveDetailCubit(
        getIt(),
        getIt<EnLogger>(),
      )..fetchMoveDetail(moveName),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                capitalizedName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              BlocBuilder<MoveDetailCubit, MoveDetailState>(
                builder: (context, state) {
                  if (state is MoveDetailLoading || state is MoveDetailInitial) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is MoveDetailError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
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

    final damageClassName = context.translateDamageClass(moveDetail.damageClass);

    final effectText = moveDetail.flavorTexts[locale] 
        ?? moveDetail.flavorTexts['en'] 
        ?? '-';

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
            _StatBadge(label: t.moveDetailPower, value: moveDetail.power?.toString() ?? '-'),
            _StatBadge(label: t.moveDetailAccuracy, value: moveDetail.accuracy?.toString() ?? '-'),
            _StatBadge(label: t.moveDetailPP, value: moveDetail.pp?.toString() ?? '-'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          t.moveDetailEffect,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          effectText.replaceAll('\n', ' '),
          style: const TextStyle(fontSize: 14),
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
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
