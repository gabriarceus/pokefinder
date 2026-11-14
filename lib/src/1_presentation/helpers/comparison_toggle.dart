import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/router/app_routes.dart';
import 'package:pokefinder/src/2_application/bloc/comparison_cubit/comparison_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Toggles [summary] in the comparison selection and shows a snackbar for an
/// addition or a full selection.
void toggleComparison(BuildContext context, PokemonSummary summary) {
  final cubit = context.read<ComparisonCubit>();
  final wasSelected = cubit.isSelected(summary.id);
  final nowSelected = cubit.toggleEntry(summary);
  final t = context.t();
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  if (nowSelected) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(t.compareAdded),
        persist: false,
        action: SnackBarAction(
          label: t.compareView,
          onPressed: () => context.push(AppRoutes.compare),
        ),
      ),
    );
  } else if (!wasSelected) {
    messenger.showSnackBar(SnackBar(content: Text(t.compareFull)));
  }
}
