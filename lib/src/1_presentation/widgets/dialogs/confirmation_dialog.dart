import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/theme/app_palette.dart';

/// Displays an alert dialog requesting user confirmation for an action.
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmLabel,
  required String cancelLabel,
  Color? confirmBackgroundColor,
  Color? confirmForegroundColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmBackgroundColor,
            foregroundColor: confirmForegroundColor,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Displays an alert dialog requesting confirmation to clear the application cache.
Future<bool?> showClearCacheConfirmationDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return showConfirmationDialog(
    context: context,
    title: t.clearCache,
    content: t.clearCacheConfirmation,
    confirmLabel: t.clear,
    cancelLabel: t.cancel,
    confirmBackgroundColor: AppPalette.brandRed,
    confirmForegroundColor: AppPalette.onBrandRed,
  );
}
